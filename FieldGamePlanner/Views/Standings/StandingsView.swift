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
                    VStack(spacing: 16) {
                        Image(systemName: "list.number")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No Standings")
                            .font(.headline)
                        Text("No standings available yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else {
                    List {
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

                            ForEach(Array(viewModel.sortedStandings.enumerated()), id: \.element.id) { index, standing in
                                StandingRow(standing: standing, position: index + 1)
                            }
                        } header: {
                            Text("League Table")
                                .font(.headline)
                                .foregroundColor(.etonPrimary)
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
