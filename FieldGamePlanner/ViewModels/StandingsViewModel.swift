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

    private let supabaseService = SupabaseService.shared
    private let cacheService = CacheService.shared

    // MARK: - Computed Properties

    /// Standings sorted by points (position is calculated by sort order)
    var sortedStandings: [LeagueStanding] {
        standings.sortedByPosition
    }

    // MARK: - Data Fetching

    func fetchStandings() async {
        isLoading = true
        errorMessage = nil

        // Try cache first
        let cacheKey = CacheKey.standings
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
            let fetched = try await supabaseService.fetchStandings()

            standings = fetched

            // Cache the results
            let cacheKey = CacheKey.standings
            await cacheService.setWithDiskPersistence(
                cacheKey,
                value: fetched,
                ttl: 600
            )

            isLoading = false
        } catch {
            isLoading = false
            if standings.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
    }
}
