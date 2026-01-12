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
    @Published var matches: [MatchWithHouses] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: TimeFilter = .week
    @Published var selectedTeamId: UUID?
    @Published var isOffline = false
    @Published var lastUpdated: Date?

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

    var filteredMatches: [MatchWithHouses] {
        var result = matches

        if let teamId = selectedTeamId {
            result = result.filter { $0.involves(teamId: teamId) }
        }

        return result.sortedByDate
    }

    var groupedByDate: [Date: [MatchWithHouses]] {
        filteredMatches.groupedByDate
    }

    var sortedDates: [Date] {
        groupedByDate.keys.sorted()
    }

    // MARK: - Data Fetching

    func fetchMatches() async {
        isLoading = true
        errorMessage = nil

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

    private func loadFromCache() async {
        let cacheKey = CacheKey.upcomingMatches
        if let cached: [MatchWithHouses] = await cacheService.getWithDiskFallback(
            cacheKey,
            type: [MatchWithHouses].self,
            diskMaxAge: nil // Accept any age when offline
        ) {
            matches = cached
        } else if matches.isEmpty {
            errorMessage = "No cached data available. Connect to the internet to load fixtures."
        }
    }

    private func refreshFromNetwork() async {
        do {
            let range = selectedFilter.dateRange
            print("[FixturesVM] Fetching matches from \(range.start) to \(range.end)")

            let fetched = try await supabaseService.fetchUpcomingMatches(
                startDate: range.start,
                endDate: range.end,
                teamId: selectedTeamId
            )

            print("[FixturesVM] Fetched \(fetched.count) matches")
            matches = fetched
            lastUpdated = Date()
            isOffline = false

            // Cache the results
            await cacheService.setWithDiskPersistence(
                CacheKey.upcomingMatches,
                value: fetched,
                ttl: 300
            )
        } catch {
            print("[FixturesVM] Error fetching matches: \(error)")
            // Network failed, try cache
            await loadFromCache()
            isOffline = true

            // Only show error if we don't have cached data
            if matches.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
    }

    func applyFilter(_ filter: TimeFilter) async {
        selectedFilter = filter
        await fetchMatches()
    }

    func filterByTeam(_ teamId: UUID?) async {
        selectedTeamId = teamId
        await fetchMatches()
    }
}
