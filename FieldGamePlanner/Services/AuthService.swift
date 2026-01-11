//
//  AuthService.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation
import Combine
import Security
import LocalAuthentication

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false
    @Published var currentUserProfile: UserProfile?
    @Published var isBiometricAvailable = false
    @Published var biometricType: BiometricType = .none

    private let keychainService = "com.eton.fieldgameplanner"
    private let keychainEmailKey = "user_email"
    private let keychainTokenKey = "auth_token"

    enum BiometricType {
        case none
        case touchID
        case faceID
    }

    private init() {
        checkBiometricAvailability()
        Task {
            await checkAuthStatus()
        }
    }

    // MARK: - Biometric Authentication

    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometricAvailable = true
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
            default:
                biometricType = .none
            }
        } else {
            isBiometricAvailable = false
            biometricType = .none
        }
    }

    func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        let reason = "Sign in to Field Game Planner"

        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if let error = error {
                    continuation.resume(throwing: AuthError.biometricFailed(error.localizedDescription))
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    // MARK: - Keychain Operations

    func saveCredentials(email: String, token: String) {
        saveToKeychain(key: keychainEmailKey, value: email)
        saveToKeychain(key: keychainTokenKey, value: token)
    }

    func getSavedEmail() -> String? {
        getFromKeychain(key: keychainEmailKey)
    }

    func hasSavedCredentials() -> Bool {
        getFromKeychain(key: keychainTokenKey) != nil
    }

    func clearCredentials() {
        deleteFromKeychain(key: keychainEmailKey)
        deleteFromKeychain(key: keychainTokenKey)
    }

    private func saveToKeychain(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }

    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Authentication Status

    func checkAuthStatus() async {
        let authenticated = await SupabaseService.shared.isAuthenticated
        isAuthenticated = authenticated

        if authenticated {
            do {
                currentUserProfile = try await SupabaseService.shared.fetchCurrentUserProfile()
            } catch {
                currentUserProfile = nil
            }
        } else {
            currentUserProfile = nil
        }
    }

    // MARK: - Sign In/Out

    func signIn(email: String, password: String, rememberMe: Bool = false) async throws {
        try await SupabaseService.shared.signIn(email: email, password: password)

        if rememberMe {
            saveCredentials(email: email, token: "authenticated")
        }

        await checkAuthStatus()
    }

    func signInWithBiometrics() async throws {
        guard hasSavedCredentials() else {
            throw AuthError.noSavedCredentials
        }

        let success = try await authenticateWithBiometrics()
        if success {
            await checkAuthStatus()
        }
    }

    func signOut() async throws {
        try await SupabaseService.shared.signOut()
        clearCredentials()
        isAuthenticated = false
        currentUserProfile = nil
    }

    // MARK: - Password Reset

    func sendPasswordReset(email: String) async throws {
        // This would call a Supabase password reset function
        // For now, we'll simulate it
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }

        // In a real implementation, call:
        // try await supabaseClient.auth.resetPasswordForEmail(email)
    }

    // MARK: - Permissions

    var canEditScores: Bool {
        guard let profile = currentUserProfile else { return false }
        return profile.role.canEditScores
    }

    var isAdmin: Bool {
        guard let profile = currentUserProfile else { return false }
        return profile.role.isAdmin
    }

    func canEditScore(for teamId: UUID) -> Bool {
        guard let profile = currentUserProfile else { return false }
        return profile.canEditScore(for: teamId)
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidEmail
    case biometricFailed(String)
    case noSavedCredentials
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .biometricFailed(let message):
            return "Biometric authentication failed: \(message)"
        case .noSavedCredentials:
            return "No saved credentials found"
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}
