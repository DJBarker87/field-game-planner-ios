//
//  SettingsView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var authService = AuthService.shared
    @State private var showingHousePicker = false
    @State private var showingSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // Preferences Section
                Section("Preferences") {
                    Button {
                        showingHousePicker = true
                    } label: {
                        HStack {
                            Label("My House", systemImage: "house")
                            Spacer()
                            if !appState.myHouse.isEmpty {
                                Text(appState.myHouse)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Not Set")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }

                // Account Section
                Section("Account") {
                    if authService.isAuthenticated {
                        if let profile = authService.currentUserProfile {
                            // User Info
                            HStack {
                                Label("Email", systemImage: "envelope")
                                Spacer()
                                Text(profile.email)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            if let name = profile.name {
                                HStack {
                                    Label("Name", systemImage: "person")
                                    Spacer()
                                    Text(name)
                                        .foregroundColor(.secondary)
                                }
                            }

                            HStack {
                                Label("Role", systemImage: "person.badge.key")
                                Spacer()
                                RoleBadge(role: profile.role)
                            }

                            if let houseName = profile.houseName {
                                HStack {
                                    Label("House", systemImage: "house.fill")
                                    Spacer()
                                    Text(houseName)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Sign Out Button
                        Button(role: .destructive) {
                            showingSignOutConfirmation = true
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } else {
                        NavigationLink {
                            LoginView()
                        } label: {
                            Label("Sign In", systemImage: "person.circle")
                        }

                        Text("Sign in to submit scores and access additional features.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Data Section
                Section("Data") {
                    Button {
                        Task {
                            await CacheService.shared.clearAll()
                        }
                    } label: {
                        Label("Clear Cache", systemImage: "trash")
                    }
                }

                // About Section
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Build", systemImage: "hammer")
                        Spacer()
                        Text(buildNumber)
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://www.etoncollege.com")!) {
                        Label("Eton College", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingHousePicker) {
                HousePickerView()
            }
            .confirmationDialog(
                "Sign Out",
                isPresented: $showingSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    Task {
                        try? await authService.signOut()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Role Badge

struct RoleBadge: View {
    let role: UserRole

    var body: some View {
        Text(role.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(roleColor)
            .cornerRadius(4)
    }

    private var roleColor: Color {
        switch role {
        case .admin:
            return .red
        case .captain:
            return .etonPrimary
        case .viewer:
            return .gray
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
