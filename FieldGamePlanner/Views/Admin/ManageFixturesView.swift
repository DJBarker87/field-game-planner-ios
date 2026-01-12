//
//  ManageFixturesView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct ManageFixturesView: View {
    @State private var selectedTab = 0
    @State private var searchDate = Date()
    @State private var searchTeam = ""
    @State private var matches: [MatchWithHouses] = []
    @State private var isLoading = false

    private let supabaseService = SupabaseService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("Mode", selection: $selectedTab) {
                Text("Add New").tag(0)
                Text("Edit Existing").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                AddFixtureView()
            } else {
                editExistingView
            }
        }
        .navigationTitle("Manage Fixtures")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Edit Existing View

    private var editExistingView: some View {
        VStack {
            // Search filters
            VStack(spacing: 12) {
                DatePicker("Date", selection: $searchDate, displayedComponents: .date)
                    .datePickerStyle(.compact)

                TextField("Search by team name", text: $searchTeam)
                    .textFieldStyle(.roundedBorder)

                Button("Search") {
                    Task { await searchFixtures() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Results
            if isLoading {
                Spacer()
                ProgressView("Searching...")
                Spacer()
            } else if matches.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Fixtures Found")
                        .font(.headline)
                    Text("Try adjusting your search criteria")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                Spacer()
            } else {
                List {
                    ForEach(matches) { match in
                        NavigationLink {
                            EditFixtureView(match: match)
                        } label: {
                            MatchSummaryRow(match: match)
                        }
                    }
                    .onDelete { indexSet in
                        Task { await deleteFixtures(at: indexSet) }
                    }
                }
            }
        }
    }

    private func searchFixtures() async {
        isLoading = true

        do {
            var fetched = try await supabaseService.fetchMatches(for: searchDate)

            if !searchTeam.isEmpty {
                fetched = fetched.filter { match in
                    match.homeTeamName.localizedCaseInsensitiveContains(searchTeam) ||
                    match.awayTeamDisplayName.localizedCaseInsensitiveContains(searchTeam)
                }
            }

            matches = fetched
        } catch {
            print("Search error: \(error)")
        }

        isLoading = false
    }

    private func deleteFixtures(at offsets: IndexSet) async {
        // In production, this would call Supabase to delete
        for index in offsets {
            let match = matches[index]
            print("Deleting match: \(match.id)")
        }
        matches.remove(atOffsets: offsets)
    }
}

// MARK: - Match Summary Row

struct MatchSummaryRow: View {
    let match: MatchWithHouses

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(match.homeTeamName)
                    .fontWeight(.medium)
                Text("vs")
                    .foregroundColor(.secondary)
                Text(match.awayTeamDisplayName)
                    .fontWeight(.medium)
            }
            .font(.subheadline)

            HStack {
                Text(match.formattedDate)
                Text("•")
                Text(match.formattedTime)
                if let location = match.fullLocationString {
                    Text("•")
                    Text(location)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Text(match.competitionType)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(match.competitionColor)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Fixture View

struct AddFixtureView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var matchDate = Date()
    @State private var matchTime = Date()
    @State private var hasTime = true
    @State private var competitionType = CompetitionType.seniorLeague
    @State private var homeTeam: House?
    @State private var awayTeam: House?
    @State private var pitchName = ""
    @State private var umpires = ""

    @State private var houses: [House] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingSuccess = false

    private let supabaseService = SupabaseService.shared
    private let cacheService = CacheService.shared

    var body: some View {
        Form {
            // Date & Time Section
            Section("Date & Time") {
                DatePicker("Date", selection: $matchDate, displayedComponents: .date)

                Toggle("Set Time", isOn: $hasTime)

                if hasTime {
                    DatePicker("Time", selection: $matchTime, displayedComponents: .hourAndMinute)
                }
            }

            // Competition Section
            Section("Competition") {
                Picker("Type", selection: $competitionType) {
                    ForEach(CompetitionType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }

            // Teams Section
            Section("Teams") {
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading houses...")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Picker("Home Team", selection: $homeTeam) {
                        Text("Select home team").tag(nil as House?)
                        ForEach(houses) { house in
                            Text(house.name).tag(house as House?)
                        }
                    }

                    Picker("Away Team", selection: $awayTeam) {
                        Text("Select away team (optional)").tag(nil as House?)
                        ForEach(houses.filter { $0.id != homeTeam?.id }) { house in
                            Text(house.name).tag(house as House?)
                        }
                    }
                }
            }

            // Location Section
            Section("Location") {
                TextField("Pitch Name (e.g., North Fields - Pitch 3)", text: $pitchName)
            }

            // Umpires Section
            Section("Umpires") {
                TextField("Umpires (optional)", text: $umpires)
            }

            // Error Section
            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            // Save Button
            Section {
                Button {
                    Task { await saveFixture() }
                } label: {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save Fixture")
                        }
                        Spacer()
                    }
                }
                .disabled(!isFormValid || isSaving)
            }
        }
        .task {
            await loadHouses()
        }
        .alert("Fixture Saved", isPresented: $showingSuccess) {
            Button("Add Another") {
                resetForm()
            }
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("The fixture has been added successfully.")
        }
    }

    private var isFormValid: Bool {
        homeTeam != nil
    }

    private func loadHouses() async {
        isLoading = true

        if let cached: [House] = await cacheService.getWithDiskFallback(
            CacheKey.houses,
            type: [House].self,
            diskMaxAge: 3600
        ) {
            houses = cached
            isLoading = false
            return
        }

        do {
            houses = try await supabaseService.fetchHouses()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func saveFixture() async {
        guard let home = homeTeam else { return }

        isSaving = true
        errorMessage = nil

        do {
            // In production, this would insert into Supabase
            // try await supabaseClient.from("matches").insert(...)

            // Simulate save
            try await Task.sleep(nanoseconds: 1_000_000_000)

            print("Saving fixture: \(home.name) vs \(awayTeam?.name ?? "TBD")")

            showingSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    private func resetForm() {
        matchDate = Date()
        matchTime = Date()
        hasTime = true
        competitionType = .seniorLeague
        homeTeam = nil
        awayTeam = nil
        pitchName = ""
        umpires = ""
        errorMessage = nil
    }
}

// MARK: - Edit Fixture View

struct EditFixtureView: View {
    let match: MatchWithHouses
    @Environment(\.dismiss) private var dismiss

    @State private var matchDate: Date
    @State private var matchTime: Date
    @State private var pitchName: String
    @State private var isSaving = false
    @State private var showingDeleteConfirmation = false
    @State private var errorMessage: String?

    init(match: MatchWithHouses) {
        self.match = match
        _matchDate = State(initialValue: match.date)
        _matchTime = State(initialValue: Date())
        _pitchName = State(initialValue: match.pitch ?? "")
    }

    var body: some View {
        Form {
            Section("Match") {
                HStack {
                    Text("Home")
                    Spacer()
                    Text(match.homeTeamName)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Away")
                    Spacer()
                    Text(match.awayTeamDisplayName)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Competition")
                    Spacer()
                    Text(match.competitionType)
                        .foregroundColor(.secondary)
                }
            }

            Section("Date & Time") {
                DatePicker("Date", selection: $matchDate, displayedComponents: .date)
                DatePicker("Time", selection: $matchTime, displayedComponents: .hourAndMinute)
            }

            Section("Location") {
                TextField("Pitch Name", text: $pitchName)
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Section {
                Button {
                    Task { await saveChanges() }
                } label: {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save Changes")
                        }
                        Spacer()
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Fixture")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Edit Fixture")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete Fixture",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task { await deleteFixture() }
            }
        } message: {
            Text("Are you sure you want to delete this fixture? This action cannot be undone.")
        }
    }

    private func saveChanges() async {
        isSaving = true
        errorMessage = nil

        do {
            // In production, update via Supabase
            try await Task.sleep(nanoseconds: 500_000_000)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    private func deleteFixture() async {
        // In production, delete via Supabase
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ManageFixturesView()
    }
}
