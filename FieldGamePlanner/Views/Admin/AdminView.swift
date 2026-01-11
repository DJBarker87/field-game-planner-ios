//
//  AdminView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Management") {
                    NavigationLink {
                        ManageCaptainsView()
                    } label: {
                        Label("Manage Captains", systemImage: "person.2.badge.key")
                    }

                    NavigationLink {
                        ManageFixturesView()
                    } label: {
                        Label("Manage Fixtures", systemImage: "calendar.badge.plus")
                    }
                }

                Section("Logs") {
                    NavigationLink {
                        ImportLogsView()
                    } label: {
                        Label("Import Logs", systemImage: "doc.text.magnifyingglass")
                    }
                }
            }
            .navigationTitle("Admin")
        }
    }
}

// Placeholder views for admin functionality
struct ManageCaptainsView: View {
    var body: some View {
        Text("Manage Captains")
            .navigationTitle("Captains")
    }
}

struct ManageFixturesView: View {
    var body: some View {
        Text("Manage Fixtures")
            .navigationTitle("Fixtures")
    }
}

struct ImportLogsView: View {
    var body: some View {
        Text("Import Logs")
            .navigationTitle("Import Logs")
    }
}

#Preview {
    AdminView()
        .environmentObject(AppState())
}
