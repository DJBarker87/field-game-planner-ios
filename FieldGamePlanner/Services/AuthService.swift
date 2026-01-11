//
//  AuthService.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation
import Combine

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false
    @Published var currentUserRole: UserRole = .anonymous

    enum UserRole: String, Codable {
        case anonymous
        case captain
        case admin
    }

    private init() {
        Task {
            await checkAuthStatus()
        }
    }

    func checkAuthStatus() async {
        let authenticated = await SupabaseService.shared.isAuthenticated
        isAuthenticated = authenticated

        if authenticated {
            // Fetch user role from profile
            currentUserRole = .anonymous // Placeholder
        } else {
            currentUserRole = .anonymous
        }
    }

    func signIn(email: String, password: String) async throws {
        try await SupabaseService.shared.signIn(email: email, password: password)
        await checkAuthStatus()
    }

    func signOut() async throws {
        try await SupabaseService.shared.signOut()
        isAuthenticated = false
        currentUserRole = .anonymous
    }
}
