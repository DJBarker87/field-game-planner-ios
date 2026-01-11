//
//  SettingsView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingHousePicker = false

    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    Button {
                        showingHousePicker = true
                    } label: {
                        HStack {
                            Label("My House", systemImage: "house")
                            Spacer()
                            Text(appState.myHouse.isEmpty ? "Not Set" : appState.myHouse)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }

                Section("Account") {
                    if appState.isAuthenticated {
                        if let user = appState.currentUser {
                            HStack {
                                Label("Email", systemImage: "envelope")
                                Spacer()
                                Text(user.email)
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Label("Role", systemImage: "person.badge.key")
                                Spacer()
                                Text(user.role.capitalized)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Button(role: .destructive) {
                            // Sign out action
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } else {
                        NavigationLink {
                            LoginView()
                        } label: {
                            Label("Sign In", systemImage: "person.circle")
                        }
                    }
                }

                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingHousePicker) {
                HousePickerView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
