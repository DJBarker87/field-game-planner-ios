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
                if viewModel.isLoading && viewModel.results.isEmpty {
                    ProgressView("Loading results...")
                } else if viewModel.results.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.badge.xmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No Results")
                            .font(.headline)
                        Text("No results available yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.competitions, id: \.self) { competition in
                            Section(competition) {
                                ForEach(viewModel.groupedByCompetition[competition] ?? []) { result in
                                    ResultCard(result: result)
                                        .listRowInsets(EdgeInsets())
                                        .listRowSeparator(.hidden)
                                        .padding(.vertical, 4)
                                }
                            }
                        }
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
