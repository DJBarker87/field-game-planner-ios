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
    @Published var standings: [Standing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabaseService = SupabaseService.shared

    var groupedStandings: [String: [Standing]] {
        Dictionary(grouping: standings, by: { $0.competition })
    }

    func fetchStandings() async {
        isLoading = true
        errorMessage = nil

        do {
            standings = try await supabaseService.fetchStandings()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func standings(for competition: String) -> [Standing] {
        standings.filter { $0.competition == competition }
            .sorted { $0.position < $1.position }
    }
}
