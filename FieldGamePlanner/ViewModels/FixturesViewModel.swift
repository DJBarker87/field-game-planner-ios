//
//  FixturesViewModel.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI
import Combine

@MainActor
class FixturesViewModel: ObservableObject {
    // MARK: - Published State

    @Published var matches: [MatchWithHouses] = []
    @Published var allMatches: [MatchWithHouses] = [] // Store all matches for umpire extraction
    @Published var houses: [House] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: TimeFilter = .all
    @Published var selectedHouse: String?  // Housemaster initials (e.g., "JDM", "HWTA")
    @Published var selectedSchoolTeam: String?  // Special team name (e.g., "Field", "College")
    @Published var selectedUmpire: String?
    @Published var viewMode: ViewMode = .list
    @Published var isOffline = false
    @Published var lastUpdated: Date?
    @Published var sourceEmailTimestamp: Date?

    private let supabaseService = SupabaseService.shared
    private let cacheService = CacheService.shared
    private let networkMonitor = NetworkMonitor.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Subscribe to network changes for auto-refresh
        networkMonitor.$isConnected
            .dropFirst() // Skip initial value
            .removeDuplicates()
            .sink { [weak self] isConnected in
                if isConnected {
                    // Back online, refresh data
                    Task { await self?.fetchMatches() }
                }
                self?.isOffline = !isConnected
            }
            .store(in: &cancellables)

        isOffline = !networkMonitor.isConnected
    }

    // MARK: - Computed Properties

    /// Separate houses from school teams
    var houseOptions: [House] {
        houses.filter { !$0.isSchoolTeam }.sortedByName
    }

    var schoolTeamOptions: [House] {
        houses.filter { $0.isSchoolTeam }.sortedByName
    }

    /// Extract unique umpire names from all matches
    var umpireOptions: [String] {
        var umpireSet = Set<String>()

        for match in allMatches {
            if let umpires = match.umpires {
                // Umpires might be comma or & separated
                let names = umpires.split { $0 == "," || $0 == "&" }
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                names.forEach { umpireSet.insert($0) }
            }
        }

        return Array(umpireSet).sorted()
    }

    /// The currently active team filter (house or school team ID)
    var activeTeamFilter: String? {
        selectedHouse ?? selectedSchoolTeam
    }

    /// Name of the selected house/team for display
    var selectedTeamName: String? {
        if let teamId = activeTeamFilter {
            return houses.first { $0.id == teamId }?.name
        }
        return nil
    }

    var filteredMatches: [MatchWithHouses] {
        var result = matches

        // Apply umpire filter client-side
        if let umpire = selectedUmpire {
            result = result.filter { match in
                guard let umpires = match.umpires else { return false }
                let umpireNames = umpires.lowercased()
                    .split { $0 == "," || $0 == "&" }
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                return umpireNames.contains { $0 == umpire.lowercased() }
            }
        }

        return result.sortedByDate
    }

    var groupedByDate: [Date: [MatchWithHouses]] {
        filteredMatches.groupedByDate
    }

    var sortedDates: [Date] {
        groupedByDate.keys.sorted()
    }

    /// Check if any filter is active (for showing calendar toggle)
    var hasActiveFilter: Bool {
        selectedHouse != nil || selectedSchoolTeam != nil || selectedUmpire != nil
    }

    // MARK: - Data Fetching

    func fetchMatches() async {
        isLoading = true
        errorMessage = nil

        // Fetch houses if not loaded
        if houses.isEmpty {
            await fetchHouses()
        }

        // Try network first if connected
        if networkMonitor.isConnected {
            await refreshFromNetwork()
            isLoading = false
            return
        }

        // Offline: load from cache
        await loadFromCache()
        isOffline = true
        isLoading = false
    }

    func fetchHouses() async {
        // Try cache first
        if let cached: [House] = await cacheService.getWithDiskFallback(
            CacheKey.houses,
            type: [House].self,
            diskMaxAge: 3600
        ) {
            houses = cached
        }

        // Refresh from network if online
        if networkMonitor.isConnected {
            do {
                let fetched = try await supabaseService.fetchHouses()
                houses = fetched
                await cacheService.setWithDiskPersistence(
                    CacheKey.houses,
                    value: fetched,
                    ttl: 3600
                )
            } catch {
                // Keep cached data if available
                if houses.isEmpty {
                    print("Failed to fetch houses: \(error)")
                }
            }
        }
    }

    private func loadFromCache() async {
        let cacheKey = CacheKey.upcomingMatches
        if let cached: [MatchWithHouses] = await cacheService.getWithDiskFallback(
            cacheKey,
            type: [MatchWithHouses].self,
            diskMaxAge: nil // Accept any age when offline
        ) {
            matches = cached
            allMatches = cached
        } else if matches.isEmpty {
            errorMessage = "No cached data available. Connect to the internet to load fixtures."
        }
    }

    private func refreshFromNetwork() async {
        do {
            let range = selectedFilter.dateRange
            let fetched = try await supabaseService.fetchUpcomingMatches(
                startDate: range.start,
                endDate: range.end,
                teamId: activeTeamFilter
            )

            matches = fetched
            lastUpdated = Date()
            isOffline = false

            // Also fetch all matches (without team filter) for umpire extraction
            if activeTeamFilter != nil || selectedUmpire != nil {
                let allFetched = try await supabaseService.fetchUpcomingMatches(
                    startDate: range.start,
                    endDate: range.end,
                    teamId: nil
                )
                allMatches = allFetched
            } else {
                allMatches = fetched
            }

            // Cache the results
            await cacheService.setWithDiskPersistence(
                CacheKey.upcomingMatches,
                value: fetched,
                ttl: 300
            )
        } catch {
            // Network failed, try cache
            await loadFromCache()
            isOffline = true

            // Only show error if we don't have cached data
            if matches.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Filter Actions

    func applyFilter(_ filter: TimeFilter) async {
        selectedFilter = filter
        await fetchMatches()
    }

    func selectHouse(_ houseId: String?) async {
        selectedHouse = houseId
        if houseId != nil {
            selectedSchoolTeam = nil
            selectedUmpire = nil
        }
        await fetchMatches()
    }

    func selectSchoolTeam(_ teamId: String?) async {
        selectedSchoolTeam = teamId
        if teamId != nil {
            selectedHouse = nil
            selectedUmpire = nil
        }
        await fetchMatches()
    }

    func selectUmpire(_ umpire: String?) async {
        selectedUmpire = umpire
        if umpire != nil {
            selectedHouse = nil
            selectedSchoolTeam = nil
        }
        // No need to refetch - umpire filter is applied client-side
    }

    func clearAllFilters() async {
        selectedHouse = nil
        selectedSchoolTeam = nil
        selectedUmpire = nil
        await fetchMatches()
    }

    func setViewMode(_ mode: ViewMode) {
        viewMode = mode
    }
}
