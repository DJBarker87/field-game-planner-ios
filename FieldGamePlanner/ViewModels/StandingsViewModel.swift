//
//  StandingsViewModel.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI
import Combine

@MainActor
class StandingsViewModel: ObservableObject {
    @Published var standings: [LeagueStanding] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCompetition: String?

    private let supabaseService = SupabaseService.shared
    private let cacheService = CacheService.shared

    // MARK: - Computed Properties

    var groupedStandings: [String: [LeagueStanding]] {
        standings.groupedByCompetition
    }

    var competitions: [String] {
        groupedStandings.keys.sorted()
    }

    var filteredStandings: [LeagueStanding] {
        if let competition = selectedCompetition {
            return standings.standings(for: competition)
        }
        return standings.sortedByPosition
    }

    // MARK: - Data Fetching

    func fetchStandings() async {
        isLoading = true
        errorMessage = nil

        // Try cache first
        let cacheKey = selectedCompetition.map { CacheKey.standings(for: $0) } ?? CacheKey.standings
        if let cached: [LeagueStanding] = await cacheService.getWithDiskFallback(
            cacheKey,
            type: [LeagueStanding].self,
            diskMaxAge: 600 // 10 minutes for standings
        ) {
            standings = cached
            isLoading = false

            // Refresh in background
            Task {
                await refreshFromNetwork()
            }
            return
        }

        await refreshFromNetwork()
    }

    private func refreshFromNetwork() async {
        do {
            let fetched = try await supabaseService.fetchStandings(
                competitionType: selectedCompetition
            )

            standings = fetched

            // Cache the results
            let cacheKey = selectedCompetition.map { CacheKey.standings(for: $0) } ?? CacheKey.standings
            await cacheService.setWithDiskPersistence(
                cacheKey,
                value: fetched,
                ttl: 600
            )
        } catch {
            if standings.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
    }

    func selectCompetition(_ competition: String?) async {
        selectedCompetition = competition
        await fetchStandings()
    }

    func standings(for competition: String) -> [LeagueStanding] {
        standings.standings(for: competition)
    }
}
