//
//  ResultsView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct ResultsView: View {
    @StateObject private var viewModel = ResultsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading results...")
                } else if viewModel.results.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "checkmark.circle.badge.xmark",
                        description: Text("No results available yet")
                    )
                } else {
                    List(viewModel.results) { result in
                        ResultCard(result: result)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Results")
            .refreshable {
                await viewModel.fetchResults()
            }
        }
        .task {
            await viewModel.fetchResults()
        }
    }
}

#Preview {
    ResultsView()
}
