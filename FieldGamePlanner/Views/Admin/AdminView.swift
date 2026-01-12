//
//  AdminView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var authService = AuthService.shared

    var body: some View {
        NavigationStack {
            if authService.isAdmin {
                adminContent
            } else {
                accessDeniedView
            }
        }
    }

    private var adminContent: some View {
        List {
            Section("User Management") {
                NavigationLink {
                    CreateCaptainView()
                } label: {
                    Label("Create Captain Account", systemImage: "person.badge.plus")
                }
            }

            Section("Fixture Management") {
                NavigationLink {
                    ManageFixturesView()
                } label: {
                    Label("Manage Fixtures", systemImage: "calendar.badge.plus")
                }
            }

            Section("System") {
                NavigationLink {
                    ImportLogsView()
                } label: {
                    Label("Import Logs", systemImage: "doc.text.magnifyingglass")
                }
            }
        }
        .navigationTitle("Admin Dashboard")
    }

    private var accessDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Access Denied")
                .font(.headline)
            Text("You must be an administrator to access this area.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if !authService.isAuthenticated {
                NavigationLink("Sign In") {
                    LoginView()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

#Preview {
    AdminView()
        .environmentObject(AppState())
}
