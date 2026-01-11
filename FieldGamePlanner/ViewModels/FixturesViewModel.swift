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

    private let supabaseService = SupabaseService.shared
    private let cacheService = CacheService.shared

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

        do {
            // Try cache first
            let cacheKey = CacheKey.upcomingMatches
            if let cached: [MatchWithHouses] = await cacheService.getWithDiskFallback(
                cacheKey,
                type: [MatchWithHouses].self,
                diskMaxAge: 300
            ) {
                matches = cached
                isLoading = false

                // Refresh in background
                Task {
                    await refreshFromNetwork()
                }
                return
            }

            await refreshFromNetwork()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func refreshFromNetwork() async {
        do {
            let range = selectedFilter.dateRange
            let fetched = try await supabaseService.fetchUpcomingMatches(
                startDate: range.start,
                endDate: range.end,
                teamId: selectedTeamId
            )

            matches = fetched

            // Cache the results
            await cacheService.setWithDiskPersistence(
                CacheKey.upcomingMatches,
                value: fetched,
                ttl: 300
            )
        } catch {
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
