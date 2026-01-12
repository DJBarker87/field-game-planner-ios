//
//  FixturesView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct FixturesView: View {
    @StateObject private var viewModel = FixturesViewModel()
    @EnvironmentObject var appState: AppState
    @State private var selectedMatch: MatchWithHouses?
    @State private var showingMyHouseSettings = false
    @State private var showingPitchMap = false
    @State private var selectedPitch: String?
    @State private var showingExportOptions = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .task {
            await viewModel.fetchMatches()
        }
        .sheet(isPresented: $showingMyHouseSettings) {
            MyHouseSettingsSheet(
                houses: viewModel.houseOptions,
                selectedHouseId: Binding(
                    get: { viewModel.houses.first { $0.name == appState.myHouse }?.id },
                    set: { newId in
                        if let house = viewModel.houses.first(where: { $0.id == newId }) {
                            appState.setMyHouse(house.name)
                            Task { await viewModel.selectHouse(newId) }
                        } else {
                            appState.setMyHouse("")
                            Task { await viewModel.selectHouse(nil) }
                        }
                    }
                )
            )
        }
        .sheet(isPresented: $showingPitchMap) {
            PitchMapSheet(
                highlightedPitch: selectedPitch,
                title: selectedPitch != nil ? "Match Location" : "Playing Fields"
            )
            .presentationDetents([.medium, .large])
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
                            Task {
                                await viewModel.applyFilter(filter)
                            }
                        } label: {
                            HStack {
                                Label(filter.rawValue, systemImage: filter.systemImage)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.etonPrimary)
                                }
                            }
                        }
                    }
                }

                Section("Filters") {
                    // House filter
                    Menu {
                        Button("All Houses") {
                            Task { await viewModel.selectHouse(nil) }
                        }
                        Divider()
                        ForEach(viewModel.houseOptions) { house in
                            Button(house.name) {
                                Task { await viewModel.selectHouse(house.id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("House", systemImage: "house")
                            Spacer()
                            if let house = viewModel.houses.first(where: { $0.id == viewModel.selectedHouse }) {
                                Text(house.name)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("All")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // School Team filter
                    Menu {
                        Button("All Teams") {
                            Task { await viewModel.selectSchoolTeam(nil) }
                        }
                        Divider()
                        ForEach(viewModel.schoolTeamOptions) { team in
                            Button(team.name) {
                                Task { await viewModel.selectSchoolTeam(team.id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("School Team", systemImage: "person.3")
                            Spacer()
                            if let team = viewModel.houses.first(where: { $0.id == viewModel.selectedSchoolTeam }) {
                                Text(team.name)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("All")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Umpire filter
                    if !viewModel.umpireOptions.isEmpty {
                        Menu {
                            Button("All Umpires") {
                                Task { await viewModel.selectUmpire(nil) }
                            }
                            Divider()
                            ForEach(viewModel.umpireOptions, id: \.self) { umpire in
                                Button(umpire) {
                                    Task { await viewModel.selectUmpire(umpire) }
                                }
                            }
                        } label: {
                            HStack {
                                Label("Umpire", systemImage: "hand.raised")
                                Spacer()
                                if let umpire = viewModel.selectedUmpire {
                                    Text(umpire)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                } else {
                                    Text("All")
                                        .foregroundColor(.secondary)
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
            fixturesContent
                .navigationTitle("Fixtures")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        viewModeToggle
                    }
                }
        } detail: {
            if let match = selectedMatch {
                MatchDetailView(match: match)
            } else {
                ContentUnavailableView(
                    "Select a Match",
                    systemImage: "sportscourt",
                    description: Text("Choose a match from the list to see details")
                )
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

                ScrollView {
                    VStack(spacing: 16) {
                        // Header with last updated
                        headerSection

                        // Time filter segmented control (only in list view)
                        if viewModel.viewMode == .list {
                            timeFilterSection
                        }

                        // Filter dropdowns (only in list view)
                        if viewModel.viewMode == .list {
                            filterSection
                        }

                        // Export buttons (only in list view)
                        if viewModel.viewMode == .list {
                            exportSection
                        }

                        // Match list or calendar
                        contentSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Fixtures")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isOffline {
                        OfflineIndicator()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if viewModel.hasActiveFilter {
                            viewModeToggle
                        }
                        settingsButton
                    }
                }
            }
            .refreshable {
                await viewModel.fetchMatches()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Active filter indicator
            if let teamName = viewModel.selectedTeamName {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundColor(.etonPrimary)
                    Text("Filtering for \(teamName)")
                        .font(.subheadline)
                        .foregroundColor(.eton600)
                }
            } else if let umpire = viewModel.selectedUmpire {
                HStack(spacing: 6) {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.etonPrimary)
                    Text("Showing matches for umpire: \(umpire)")
                        .font(.subheadline)
                        .foregroundColor(.eton600)
                }
            }

            // Last updated badge
            if let lastUpdated = viewModel.lastUpdated {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.etonPrimary)
                        .frame(width: 6, height: 6)
                    Text("Updated \(lastUpdated.relativeDescription)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Time Filter Section

    private var timeFilterSection: some View {
        SegmentedControlView(selection: Binding(
            get: { viewModel.selectedFilter },
            set: { newFilter in
                Task { await viewModel.applyFilter(newFilter) }
            }
        ))
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(spacing: 12) {
            // House and School Team in a row
            HStack(spacing: 12) {
                HouseFilterDropdown(
                    title: "House",
                    options: viewModel.houseOptions,
                    selection: Binding(
                        get: { viewModel.selectedHouse },
                        set: { newId in
                            Task { await viewModel.selectHouse(newId) }
                        }
                    ),
                    allLabel: "All Houses"
                )

                SchoolTeamFilterDropdown(
                    options: viewModel.schoolTeamOptions,
                    selection: Binding(
                        get: { viewModel.selectedSchoolTeam },
                        set: { newId in
                            Task { await viewModel.selectSchoolTeam(newId) }
                        }
                    ),
                    allLabel: "All Teams"
                )
            }

            // Umpire filter
            if !viewModel.umpireOptions.isEmpty {
                UmpireFilterDropdown(
                    options: viewModel.umpireOptions,
                    selection: Binding(
                        get: { viewModel.selectedUmpire },
                        set: { newUmpire in
                            Task { await viewModel.selectUmpire(newUmpire) }
                        }
                    ),
                    allLabel: "All Umpires"
                )
            }
        }
    }

    // MARK: - Export Section

    private var exportSection: some View {
        HStack(spacing: 12) {
            Spacer()

            Button {
                exportToCalendar()
            } label: {
                Label("Export to Calendar", systemImage: "calendar.badge.plus")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.filteredMatches.isEmpty)

            ShareLink(
                item: generateFixturesText(),
                subject: Text("Field Game Fixtures"),
                message: Text("Fixtures from Field Game Planner")
            ) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.filteredMatches.isEmpty)
        }
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading && viewModel.matches.isEmpty {
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading fixtures...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else if viewModel.viewMode == .calendar {
            MonthlyCalendarView(
                matches: viewModel.selectedUmpire != nil ? viewModel.filteredMatches : viewModel.allMatches,
                selectedTeamId: viewModel.activeTeamFilter,
                onDateClick: { date in
                    // Switch to list view and filter to that date
                    viewModel.setViewMode(.list)
                    // Could add date-specific filtering here
                },
                onPitchClick: { pitch in
                    selectedPitch = pitch
                    showingPitchMap = true
                }
            )
        } else {
            matchListContent
        }
    }

    @ViewBuilder
    private var matchListContent: some View {
        if viewModel.filteredMatches.isEmpty {
            emptyStateView
        } else {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.sortedDates, id: \.self) { date in
                    if let matches = viewModel.groupedByDate[date] {
                        Section {
                            ForEach(matches) { match in
                                MatchCard(
                                    match: match,
                                    showScoreEntry: true,
                                    onPitchTap: {
                                        selectedPitch = match.pitch
                                        showingPitchMap = true
                                    }
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
                            .padding(.top, 8)
                        }
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text(emptyStateTitle)
                .font(.headline)

            Text(emptyStateSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    private var emptyStateTitle: String {
        if viewModel.selectedUmpire != nil {
            return "No fixtures found"
        }
        switch viewModel.selectedFilter {
        case .today:
            return "No fixtures today"
        case .tomorrow:
            return "No fixtures tomorrow"
        default:
            return "No upcoming fixtures"
        }
    }

    private var emptyStateSubtitle: String {
        if viewModel.selectedUmpire != nil {
            return "You may not be assigned to any matches in this time period."
        }
        switch viewModel.selectedFilter {
        case .today, .tomorrow:
            return "Check back later or view all upcoming fixtures."
        default:
            return "Try adjusting your filters to see more results."
        }
    }

    // MARK: - Toolbar Items

    @ViewBuilder
    private var viewModeToggle: some View {
        HStack(spacing: 4) {
            Button {
                viewModel.setViewMode(.list)
            } label: {
                Image(systemName: "list.bullet")
                    .padding(6)
                    .background(viewModel.viewMode == .list ? Color(.systemGray5) : Color.clear)
                    .cornerRadius(6)
            }
            .foregroundColor(viewModel.viewMode == .list ? .primary : .secondary)

            Button {
                viewModel.setViewMode(.calendar)
            } label: {
                Image(systemName: "calendar")
                    .padding(6)
                    .background(viewModel.viewMode == .calendar ? Color(.systemGray5) : Color.clear)
                    .cornerRadius(6)
            }
            .foregroundColor(viewModel.viewMode == .calendar ? .primary : .secondary)
        }
        .padding(2)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private var settingsButton: some View {
        Button {
            showingMyHouseSettings = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "gearshape")
                if !appState.myHouse.isEmpty {
                    Text(appState.myHouse)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
    }

    // MARK: - Shared Content

    @ViewBuilder
    private var fixturesContent: some View {
        if viewModel.isLoading && viewModel.matches.isEmpty {
            ProgressView("Loading fixtures...")
        } else if viewModel.filteredMatches.isEmpty {
            ContentUnavailableView(
                emptyStateTitle,
                systemImage: "calendar.badge.exclamationmark",
                description: Text(emptyStateSubtitle)
            )
        } else if viewModel.viewMode == .calendar {
            MonthlyCalendarView(
                matches: viewModel.selectedUmpire != nil ? viewModel.filteredMatches : viewModel.allMatches,
                selectedTeamId: viewModel.activeTeamFilter,
                onDateClick: { date in
                    viewModel.setViewMode(.list)
                },
                onPitchClick: { pitch in
                    selectedPitch = pitch
                    showingPitchMap = true
                }
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
                                        showScoreEntry: true,
                                        onPitchTap: {
                                            selectedPitch = match.pitch
                                            showingPitchMap = true
                                        }
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

    // MARK: - Export Functions

    private func exportToCalendar() {
        Task {
            let service = CalendarExportService.shared
            do {
                let count = try await service.exportMatches(viewModel.filteredMatches)
                // Could show a success toast here
                print("Exported \(count) matches to calendar")
            } catch {
                print("Failed to export: \(error)")
            }
        }
    }

    private func generateFixturesText() -> String {
        var text = "Field Game Fixtures\n"
        text += "Generated: \(Date().displayString)\n"
        text += String(repeating: "=", count: 40) + "\n\n"

        let grouped = viewModel.filteredMatches.groupedByDate
        for date in grouped.keys.sorted() {
            guard let matches = grouped[date] else { continue }

            text += "\(date.displayStringWithDay)\n"
            text += String(repeating: "-", count: 30) + "\n"

            for match in matches {
                let time = match.time ?? "TBD"
                text += "\(time)  \(match.homeTeamName) v \(match.awayTeamName ?? "TBD")\n"
                if let pitch = match.pitch {
                    text += "       \(pitch) (\(match.competitionType))\n"
                }
            }
            text += "\n"
        }

        return text
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

                    if let umpires = match.umpires {
                        DetailRow(icon: "hand.raised", title: "Umpires", value: umpires)
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

// MARK: - My House Settings Sheet

struct MyHouseSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let houses: [House]
    @Binding var selectedHouseId: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Select your house to automatically filter fixtures. Your preference will be saved for future visits.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section {
                    // No preference option
                    Button {
                        selectedHouseId = nil
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: selectedHouseId == nil ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedHouseId == nil ? .etonPrimary : .secondary)
                            Text("Show all fixtures")
                                .foregroundColor(.primary)
                        }
                    }

                    // House options
                    ForEach(houses) { house in
                        Button {
                            selectedHouseId = house.id
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: selectedHouseId == house.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedHouseId == house.id ? .etonPrimary : .secondary)
                                AsyncHouseCrestImage(
                                    imagePath: house.crestImagePath,
                                    size: 24,
                                    fallbackColors: house.parsedColours
                                )
                                Text(house.name)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My House")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FixturesView()
        .environmentObject(AppState())
}
