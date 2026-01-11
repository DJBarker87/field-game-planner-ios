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
                if viewModel.isLoading && viewModel.standings.isEmpty {
                    ProgressView("Loading standings...")
                } else if viewModel.standings.isEmpty {
                    ContentUnavailableView(
                        "No Standings",
                        systemImage: "list.number",
                        description: Text("No standings available yet")
                    )
                } else {
                    List {
                        ForEach(viewModel.competitions, id: \.self) { competition in
                            Section {
                                // Header row
                                HStack {
                                    Text("#")
                                        .frame(width: 30, alignment: .leading)
                                    Text("Team")
                                    Spacer()
                                    HStack(spacing: 12) {
                                        Text("P").frame(width: 28)
                                        Text("W").frame(width: 28)
                                        Text("D").frame(width: 28)
                                        Text("L").frame(width: 28)
                                        Text("GD").frame(width: 28)
                                        Text("Pts").frame(width: 28)
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)

                                ForEach(viewModel.standings(for: competition)) { standing in
                                    StandingRow(standing: standing)
                                }
                            } header: {
                                Text(competition)
                                    .font(.headline)
                                    .foregroundColor(.etonPrimary)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Standings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("All Competitions") {
                            Task {
                                await viewModel.selectCompetition(nil)
                            }
                        }
                        Divider()
                        ForEach(viewModel.competitions, id: \.self) { competition in
                            Button(competition) {
                                Task {
                                    await viewModel.selectCompetition(competition)
                                }
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
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
