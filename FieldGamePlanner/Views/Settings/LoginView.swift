//
//  LoginView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared

    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingForgotPassword = false
    @State private var showingResetConfirmation = false

    var body: some View {
        Form {
            // Credentials Section
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                    .textContentType(.password)

                Toggle("Remember Me", isOn: $rememberMe)
            }

            // Error Message
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            // Sign In Button
            Section {
                Button {
                    Task { await signIn() }
                } label: {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Sign In")
                        }
                        Spacer()
                    }
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)
            }

            // Biometric Sign In
            if authService.isBiometricAvailable && authService.hasSavedCredentials() {
                Section {
                    Button {
                        Task { await signInWithBiometrics() }
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: biometricIcon)
                            Text("Sign in with \(biometricName)")
                            Spacer()
                        }
                    }
                }
            }

            // Forgot Password
            Section {
                Button {
                    showingForgotPassword = true
                } label: {
                    Text("Forgot Password?")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Pre-fill saved email if available
            if let savedEmail = authService.getSavedEmail() {
                email = savedEmail
            }
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordSheet(
                email: email,
                showConfirmation: $showingResetConfirmation
            )
        }
        .alert("Password Reset Sent", isPresented: $showingResetConfirmation) {
            Button("OK") { }
        } message: {
            Text("Check your email for instructions to reset your password.")
        }
    }

    private var biometricIcon: String {
        authService.biometricType == .faceID ? "faceid" : "touchid"
    }

    private var biometricName: String {
        authService.biometricType == .faceID ? "Face ID" : "Touch ID"
    }

    private func signIn() async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.signIn(email: email, password: password, rememberMe: rememberMe)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func signInWithBiometrics() async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.signInWithBiometrics()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Forgot Password Sheet

struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State var email: String
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var showConfirmation: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button {
                        Task { await sendResetLink() }
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Send Reset Link")
                            }
                            Spacer()
                        }
                    }
                    .disabled(email.isEmpty || isLoading)
                }
            }
            .navigationTitle("Reset Password")
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

    private func sendResetLink() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AuthService.shared.sendPasswordReset(email: email)
            dismiss()
            showConfirmation = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AppState())
    }
}
