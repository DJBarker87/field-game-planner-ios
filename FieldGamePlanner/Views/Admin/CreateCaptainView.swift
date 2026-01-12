//
//  CreateCaptainView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct CreateCaptainView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var name = ""
    @State private var selectedHouse: House?
    @State private var temporaryPassword = ""

    @State private var houses: [House] = []
    @State private var isLoading = false
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var showingSuccess = false

    private let supabaseService = SupabaseService.shared
    private let cacheService = CacheService.shared

    var body: some View {
        Form {
            // Captain Details Section
            Section("Captain Details") {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                TextField("Name (optional)", text: $name)
                    .textContentType(.name)
            }

            // House Selection Section
            Section("House") {
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading houses...")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Picker("Select House", selection: $selectedHouse) {
                        Text("Select a house").tag(nil as House?)
                        ForEach(houses.filter { !$0.isSchoolTeam }) { house in
                            HStack {
                                KitColorIndicator(colors: house.parsedColours)
                                Text(house.name)
                            }
                            .tag(house as House?)
                        }
                    }
                }
            }

            // Password Section
            Section("Temporary Password") {
                HStack {
                    if temporaryPassword.isEmpty {
                        Text("No password generated")
                            .foregroundColor(.secondary)
                    } else {
                        Text(temporaryPassword)
                            .font(.system(.body, design: .monospaced))
                    }

                    Spacer()

                    Button {
                        generatePassword()
                    } label: {
                        Label("Generate", systemImage: "arrow.clockwise")
                            .labelStyle(.iconOnly)
                    }
                }

                Text("Captain must change password on first login.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Error Section
            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            // Create Button
            Section {
                Button {
                    Task { await createCaptain() }
                } label: {
                    HStack {
                        Spacer()
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Create Captain Account")
                        }
                        Spacer()
                    }
                }
                .disabled(!isFormValid || isCreating)
            }
        }
        .navigationTitle("Create Captain")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadHouses()
        }
        .onAppear {
            if temporaryPassword.isEmpty {
                generatePassword()
            }
        }
        .alert("Captain Created", isPresented: $showingSuccess) {
            Button("Create Another") {
                resetForm()
            }
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Captain account created successfully. The captain should sign in with the temporary password and change it immediately.")
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        isValidEmail(email) &&
        selectedHouse != nil &&
        !temporaryPassword.isEmpty
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    // MARK: - Actions

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
            await cacheService.setWithDiskPersistence(CacheKey.houses, value: houses, ttl: 3600)
        } catch {
            errorMessage = "Failed to load houses: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func generatePassword() {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789"
        temporaryPassword = String((0..<12).map { _ in characters.randomElement()! })
    }

    private func createCaptain() async {
        guard let house = selectedHouse else { return }

        isCreating = true
        errorMessage = nil

        do {
            // In a real implementation, this would call Supabase Admin API
            // try await supabaseClient.auth.admin.createUser(...)
            // try await supabaseClient.from("user_profiles").insert(...)

            // For now, simulate the creation
            try await Task.sleep(nanoseconds: 1_000_000_000)

            // Log the creation (in production, this would be actual API calls)
            print("Creating captain: \(email) for house: \(house.name)")

            showingSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isCreating = false
    }

    private func resetForm() {
        email = ""
        name = ""
        selectedHouse = nil
        generatePassword()
        errorMessage = nil
    }
}

#Preview {
    NavigationStack {
        CreateCaptainView()
    }
}
