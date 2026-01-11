//
//  FixturesView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct FixturesView: View {
    @StateObject private var viewModel = FixturesViewModel()
    @State private var selectedFilter: TimeFilter = .week

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Offline banner
                if viewModel.isOffline {
                    OfflineBanner(lastUpdated: viewModel.lastUpdated)
                }

                // Content
                Group {
                    if viewModel.isLoading && viewModel.matches.isEmpty {
                        ProgressView("Loading fixtures...")
                    } else if viewModel.matches.isEmpty {
                        ContentUnavailableView(
                            "No Fixtures",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("No upcoming fixtures available")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.sortedDates, id: \.self) { date in
                                    if let matches = viewModel.groupedByDate[date] {
                                        Section {
                                            ForEach(matches) { match in
                                                MatchCard(
                                                    match: match,
                                                    showScoreEntry: true
                                                ) {
                                                    // Refresh after score submission
                                                    Task {
                                                        await viewModel.fetchMatches()
                                                    }
                                                }
                                            }
                                        } header: {
                                            HStack {
                                                Text(date.relativeDescription)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Text(date.displayString)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal)
                                            .padding(.top, 8)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Fixtures")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isOffline {
                        OfflineIndicator()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(TimeFilter.allCases) { filter in
                            Button {
                                Task {
                                    await viewModel.applyFilter(filter)
                                }
                            } label: {
                                Label(filter.rawValue, systemImage: filter.systemImage)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.fetchMatches()
            }
        }
        .task {
            await viewModel.fetchMatches()
        }
    }
}

#Preview {
    FixturesView()
}
