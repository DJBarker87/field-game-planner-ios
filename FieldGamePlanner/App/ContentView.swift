//
//  ContentView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FixturesView()
                .tabItem {
                    Label("Fixtures", systemImage: "calendar")
                }
                .tag(0)

            ResultsView()
                .tabItem {
                    Label("Results", systemImage: "checkmark.circle")
                }
                .tag(1)

            StandingsView()
                .tabItem {
                    Label("Standings", systemImage: "list.number")
                }
                .tag(2)

            PitchMapsView()
                .tabItem {
                    Label("Pitches", systemImage: "map")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(Color.etonGreen)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
