//
//  ResultsViewModel.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI
import Combine

@MainActor
class ResultsViewModel: ObservableObject {
    @Published var results: [MatchWithHouses] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTeamId: String?  // Team ID (housemaster initials or special team name)
    @Published var selectedYear: Int?

    private let supabaseService = SupabaseService.shared
    private let cacheService = CacheService.shared

    // MARK: - Computed Properties

    var filteredResults: [MatchWithHouses] {
        var result = results

        if let teamId = selectedTeamId {
            result = result.filter { $0.involves(teamId: teamId) }
        }

        return result
    }

    var groupedByCompetition: [String: [MatchWithHouses]] {
        filteredResults.groupedByCompetition
    }

    var competitions: [String] {
        groupedByCompetition.keys.sorted()
    }

    // MARK: - Data Fetching

    func fetchResults() async {
        isLoading = true
        errorMessage = nil

        // Try cache first
        let cacheKey = CacheKey.recentResults
        if let cached: [MatchWithHouses] = await cacheService.getWithDiskFallback(
            cacheKey,
            type: [MatchWithHouses].self,
            diskMaxAge: 300
        ) {
            results = cached
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
            let fetched = try await supabaseService.fetchRecentResults(
                teamId: selectedTeamId,
                year: selectedYear
            )

            results = fetched

            // Cache the results
            await cacheService.setWithDiskPersistence(
                CacheKey.recentResults,
                value: fetched,
                ttl: 300
            )
        } catch {
            if results.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
    }

    func filterByTeam(_ teamId: String?) async {
        selectedTeamId = teamId
        await fetchResults()
    }

    func filterByYear(_ year: Int?) async {
        selectedYear = year
        await fetchResults()
    }

    // MARK: - Statistics

    func stats(for teamId: String) -> TeamStats {
        let teamResults = results.filter { $0.involves(teamId: teamId) }

        var wins = 0
        var draws = 0
        var losses = 0
        var goalsFor = 0
        var goalsAgainst = 0

        for match in teamResults {
            guard let homeScore = match.homeScore, let awayScore = match.awayScore else { continue }

            let isHome = match.homeTeamId == teamId
            let teamScore = isHome ? homeScore : awayScore
            let opponentScore = isHome ? awayScore : homeScore

            goalsFor += teamScore
            goalsAgainst += opponentScore

            if teamScore > opponentScore {
                wins += 1
            } else if teamScore < opponentScore {
                losses += 1
            } else {
                draws += 1
            }
        }

        return TeamStats(
            played: teamResults.count,
            wins: wins,
            draws: draws,
            losses: losses,
            goalsFor: goalsFor,
            goalsAgainst: goalsAgainst
        )
    }
}

struct TeamStats {
    let played: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int

    var goalDifference: Int { goalsFor - goalsAgainst }
    var points: Int { wins * 3 + draws }
}
