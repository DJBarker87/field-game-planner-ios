//
//  FixturesView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct FixturesView: View {
    @StateObject private var viewModel = FixturesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading fixtures...")
                } else if viewModel.matches.isEmpty {
                    ContentUnavailableView(
                        "No Fixtures",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No upcoming fixtures available")
                    )
                } else {
                    List(viewModel.matches) { match in
                        MatchCard(match: match)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Fixtures")
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
