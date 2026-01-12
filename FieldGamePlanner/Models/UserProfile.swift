//
//  UserProfile.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

/// User profile model representing authenticated users
struct UserProfile: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let name: String?
    let role: UserRole
    let houseId: String?
    let houseName: String?
    let createdAt: Date?
    let updatedAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case role
        case houseId = "house_id"
        case houseName = "house_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - Computed Properties

    /// Display name (name or email prefix)
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        // Extract username from email
        return email.components(separatedBy: "@").first ?? email
    }

    /// User's initials for avatar
    var initials: String {
        if let name = name, !name.isEmpty {
            let components = name.components(separatedBy: " ")
            let firstInitial = components.first?.first.map(String.init) ?? ""
            let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
            return (firstInitial + lastInitial).uppercased()
        }
        return String(email.prefix(2)).uppercased()
    }

    /// Check if user can edit scores for a specific team
    func canEditScore(for teamId: String) -> Bool {
        // Admins can edit any score
        if role.isAdmin { return true }
        // Captains can only edit their own house's scores
        if role == .captain, let userHouseId = houseId {
            return userHouseId == teamId
        }
        return false
    }

    /// Check if user can edit a specific match
    func canEditMatch(_ match: MatchWithHouses) -> Bool {
        canEditScore(for: match.homeTeamId) || (match.awayTeamId.map { canEditScore(for: $0) } ?? false)
    }

    // MARK: - Equatable

    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Preview

    static var viewerPreview: UserProfile {
        UserProfile(
            id: "1",
            email: "viewer@example.com",
            name: "John Viewer",
            role: .viewer,
            houseId: nil,
            houseName: nil,
            createdAt: Date(),
            updatedAt: nil
        )
    }

    static var captainPreview: UserProfile {
        UserProfile(
            id: "2",
            email: "captain@example.com",
            name: "James Captain",
            role: .captain,
            houseId: "1",
            houseName: "Keate",
            createdAt: Date(),
            updatedAt: nil
        )
    }

    static var adminPreview: UserProfile {
        UserProfile(
            id: "3",
            email: "admin@example.com",
            name: "Alex Admin",
            role: .admin,
            houseId: nil,
            houseName: nil,
            createdAt: Date(),
            updatedAt: nil
        )
    }
}

// MARK: - Auth State

/// Represents the current authentication state
enum AuthState: Equatable {
    case unknown
    case unauthenticated
    case authenticated(UserProfile)

    var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        }
        return false
    }

    var user: UserProfile? {
        if case .authenticated(let profile) = self {
            return profile
        }
        return nil
    }

    var role: UserRole {
        user?.role ?? .viewer
    }
}
