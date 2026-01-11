//
//  HousePickerView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct HousePickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var houses: [House] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""

    private let supabaseService = SupabaseService.shared
    private let cacheService = CacheService.shared

    var filteredHouses: [House] {
        if searchText.isEmpty {
            return houses
        }
        return houses.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading houses...")
                } else if let error = errorMessage {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") {
                            Task { await loadHouses() }
                        }
                    }
                } else if houses.isEmpty {
                    ContentUnavailableView(
                        "No Houses",
                        systemImage: "house",
                        description: Text("No houses available")
                    )
                } else {
                    List {
                        ForEach(filteredHouses) { house in
                            HouseRow(
                                house: house,
                                isSelected: appState.myHouse == house.name
                            ) {
                                appState.setMyHouse(house.name)
                                dismiss()
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search houses")
                }
            }
            .navigationTitle("Select House")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if !appState.myHouse.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Clear") {
                            appState.setMyHouse("")
                            dismiss()
                        }
                    }
                }
            }
        }
        .task {
            await loadHouses()
        }
    }

    private func loadHouses() async {
        isLoading = true
        errorMessage = nil

        do {
            // Try cache first
            if let cached: [House] = await cacheService.getWithDiskFallback(
                CacheKey.houses,
                type: [House].self,
                diskMaxAge: 3600 // 1 hour for houses
            ) {
                houses = cached.filter { !$0.isSchoolTeam }
                isLoading = false

                // Refresh in background
                Task { await refreshFromNetwork() }
                return
            }

            await refreshFromNetwork()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func refreshFromNetwork() async {
        do {
            let fetched = try await supabaseService.fetchHouses()
            houses = fetched.filter { !$0.isSchoolTeam }

            // Cache the results
            await cacheService.setWithDiskPersistence(
                CacheKey.houses,
                value: fetched,
                ttl: 3600
            )
        } catch {
            if houses.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}

struct HouseRow: View {
    let house: House
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Kit colors
                KitColorIndicator(colors: house.parsedColours)

                // House name
                Text(house.name)
                    .foregroundColor(.primary)

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.etonGreen)
                }
            }
        }
    }
}

#Preview {
    HousePickerView()
        .environmentObject(AppState())
}
