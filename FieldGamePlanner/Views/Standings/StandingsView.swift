//
//  StandingsView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct StandingsView: View {
    @StateObject private var viewModel = StandingsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading standings...")
                } else if viewModel.standings.isEmpty {
                    ContentUnavailableView(
                        "No Standings",
                        systemImage: "list.number",
                        description: Text("No standings available yet")
                    )
                } else {
                    List {
                        ForEach(viewModel.groupedStandings.keys.sorted(), id: \.self) { competition in
                            Section(competition) {
                                ForEach(viewModel.groupedStandings[competition] ?? []) { standing in
                                    StandingRow(standing: standing)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Standings")
            .refreshable {
                await viewModel.fetchStandings()
            }
        }
        .task {
            await viewModel.fetchStandings()
        }
    }
}

#Preview {
    StandingsView()
}
