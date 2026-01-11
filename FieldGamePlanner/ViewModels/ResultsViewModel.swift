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
    @Published var results: [MatchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabaseService = SupabaseService.shared

    func fetchResults() async {
        isLoading = true
        errorMessage = nil

        do {
            results = try await supabaseService.fetchRecentResults()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func filterResults(by competition: String?) -> [MatchResult] {
        guard let competition else { return results }
        return results.filter { $0.competition == competition }
    }

    func filterResults(by house: String?) -> [MatchResult] {
        guard let house else { return results }
        return results.filter { $0.homeTeam == house || $0.awayTeam == house }
    }
}
