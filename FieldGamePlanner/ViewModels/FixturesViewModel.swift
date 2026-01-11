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
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabaseService = SupabaseService.shared

    func fetchMatches() async {
        isLoading = true
        errorMessage = nil

        do {
            matches = try await supabaseService.fetchUpcomingMatches()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func filterMatches(by competition: String?) -> [Match] {
        guard let competition else { return matches }
        return matches.filter { $0.competition == competition }
    }

    func filterMatches(by house: String?) -> [Match] {
        guard let house else { return matches }
        return matches.filter { $0.homeTeam == house || $0.awayTeam == house }
    }
}
