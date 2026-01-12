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
    @State private var selectedMatch: MatchWithHouses?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad: Split view with sidebar
                iPadLayout
            } else {
                // iPhone: Standard navigation
                iPhoneLayout
            }
        }
        .task {
            await viewModel.fetchMatches()
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        NavigationSplitView {
            // Sidebar with filters
            List {
                Section("Time Filter") {
                    ForEach(TimeFilter.allCases) { filter in
                        Button {
                            selectedFilter = filter
                            Task {
                                await viewModel.applyFilter(filter)
                            }
                        } label: {
                            HStack {
                                Label(filter.rawValue, systemImage: filter.systemImage)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.etonPrimary)
                                }
                            }
                        }
                    }
                }

                if viewModel.isOffline {
                    Section {
                        OfflineIndicator()
                    }
                }
            }
            .navigationTitle("Filters")
        } content: {
            // Main content
            fixturesContent
                .navigationTitle("Fixtures")
        } detail: {
            // Match detail (optional)
            if let match = selectedMatch {
                MatchDetailView(match: match)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "sportscourt")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Select a Match")
                        .font(.headline)
                    Text("Choose a match from the list to see details")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .refreshable {
            await viewModel.fetchMatches()
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isOffline {
                    OfflineBanner(lastUpdated: viewModel.lastUpdated)
                }
                fixturesContent
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
    }

    // MARK: - Shared Content

    @ViewBuilder
    private var fixturesContent: some View {
        if viewModel.isLoading && viewModel.matches.isEmpty {
            ProgressView("Loading fixtures...")
        } else if viewModel.matches.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("No Fixtures")
                    .font(.headline)
                Text("No upcoming fixtures available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
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
                                        Task {
                                            await viewModel.fetchMatches()
                                        }
                                    }
                                    .onTapGesture {
                                        selectedMatch = match
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

// MARK: - Match Detail View

struct MatchDetailView: View {
    let match: MatchWithHouses

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Competition badge
                Text(match.competitionType)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(match.competitionColor)
                    .cornerRadius(8)

                // Teams
                HStack(spacing: 40) {
                    TeamDetailView(
                        name: match.homeTeamName,
                        colors: match.homeKitColors,
                        score: match.homeScore,
                        isWinner: match.winner == match.homeTeamName
                    )

                    Text("vs")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    TeamDetailView(
                        name: match.awayTeamName ?? "",
                        colors: match.awayKitColors,
                        score: match.awayScore,
                        isWinner: match.winner == match.awayTeamName
                    )
                }

                Divider()

                // Details
                VStack(spacing: 16) {
                    DetailRow(icon: "calendar", title: "Date", value: match.formattedDate)
                    DetailRow(icon: "clock", title: "Time", value: match.formattedTime)

                    if let location = match.fullLocationString {
                        DetailRow(icon: "mappin.circle", title: "Location", value: location)
                    }

                    DetailRow(icon: "flag", title: "Status", value: match.status.capitalized)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Match Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TeamDetailView: View {
    let name: String
    let colors: [Color]
    let score: Int?
    let isWinner: Bool

    var body: some View {
        VStack(spacing: 12) {
            KitColorIndicator(colors: colors)
                .scaleEffect(1.5)

            Text(name)
                .font(.title3)
                .fontWeight(isWinner ? .bold : .medium)
                .multilineTextAlignment(.center)

            if let score = score {
                Text("\(score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(isWinner ? .etonPrimary : .primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    FixturesView()
}
