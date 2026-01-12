//
//  SupabaseService.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation
import Supabase

/// Thread-safe service for all Supabase database operations
actor SupabaseService {
    static let shared = SupabaseService()

    private let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
    }

    // MARK: - Houses

    /// Fetch all houses ordered by name
    /// - Returns: Array of House objects
    func fetchHouses() async throws -> [House] {
        let response: [House] = try await client
            .from("houses")
            .select()
            .order("name", ascending: true)
            .execute()
            .value

        return response
    }

    /// Fetch a single house by ID (housemaster initials)
    /// - Parameter id: The house ID (housemaster initials like "JDM", "HWTA")
    /// - Returns: The House object or nil if not found
    func fetchHouse(id: String) async throws -> House? {
        let response: [House] = try await client
            .from("houses")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // MARK: - Upcoming Matches

    /// Fetch upcoming matches with optional filters
    /// - Parameters:
    ///   - startDate: Optional start date filter
    ///   - endDate: Optional end date filter
    ///   - teamId: Optional team ID (housemaster initials) to filter matches involving this team
    /// - Returns: Array of MatchWithHouses objects
    func fetchUpcomingMatches(
        startDate: Date? = nil,
        endDate: Date? = nil,
        teamId: String? = nil
    ) async throws -> [MatchWithHouses] {
        var query = client
            .from("upcoming_matches")
            .select()

        // Apply date filters (using YYYY-MM-DD format to match database)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let start = startDate {
            let dateString = ISO8601DateFormatter().string(from: start)
            query = query.gte("date", value: dateString)
        }

        if let end = endDate {
            let dateString = ISO8601DateFormatter().string(from: end)
            query = query.lte("date", value: dateString)
        }

        // Apply team filter (matches where team is home OR away)
        if let team = teamId {
            query = query.or("home_team_id.eq.\(team),away_team_id.eq.\(team)")
        }

        let response: [MatchWithHouses] = try await query
            .order("date", ascending: true)
            .order("time", ascending: true)
            .execute()
            .value

        return response
    }

    /// Fetch matches for a specific date
    /// - Parameter date: The date to fetch matches for
    /// - Returns: Array of MatchWithHouses objects
    func fetchMatches(for date: Date) async throws -> [MatchWithHouses] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return try await fetchUpcomingMatches(startDate: startOfDay, endDate: endOfDay)
    }

    /// Fetch matches for a time filter
    /// - Parameter filter: The TimeFilter to apply
    /// - Returns: Array of MatchWithHouses objects
    func fetchMatches(for filter: TimeFilter) async throws -> [MatchWithHouses] {
        let range = filter.dateRange
        return try await fetchUpcomingMatches(startDate: range.start, endDate: range.end)
    }

    // MARK: - Recent Results

    /// Fetch recent results with optional filters
    /// - Parameters:
    ///   - teamId: Optional team ID (housemaster initials) to filter
    ///   - year: Optional year to filter (defaults to current year)
    ///   - limit: Maximum number of results to return
    /// - Returns: Array of MatchWithHouses objects (completed matches)
    func fetchRecentResults(
        teamId: String? = nil,
        year: Int? = nil,
        limit: Int = 50
    ) async throws -> [MatchWithHouses] {
        var query = client
            .from("recent_results")
            .select()

        // Filter to current calendar year by default (using YYYY-MM-DD format)
        let targetYear = year ?? Calendar.current.component(.year, from: Date())
        let startOfYear = "\(targetYear)-01-01"
        let endOfYear = "\(targetYear + 1)-01-01"

        query = query
            .gte("date", value: startOfYear)
            .lt("date", value: endOfYear)

        // Apply team filter
        if let team = teamId {
            query = query.or("home_team_id.eq.\(team),away_team_id.eq.\(team)")
        }

        let response: [MatchWithHouses] = try await query
            .order("date", ascending: false)
            .limit(limit)
            .execute()
            .value

        return response
    }

    // MARK: - League Standings

    /// Fetch league standings
    /// - Returns: Array of LeagueStanding objects sorted by points
    func fetchStandings() async throws -> [LeagueStanding] {
        let response: [LeagueStanding] = try await client
            .from("league_standings")
            .select()
            .order("points", ascending: false)
            .order("goal_difference", ascending: false)
            .execute()
            .value

        return response
    }

    /// Fetch standings for a specific team
    /// - Parameter teamId: The team ID (housemaster initials)
    /// - Returns: Array of LeagueStanding objects for that team
    func fetchStandings(for teamId: String) async throws -> [LeagueStanding] {
        let response: [LeagueStanding] = try await client
            .from("league_standings")
            .select()
            .eq("team_id", value: teamId)
            .execute()
            .value

        return response
    }

    // MARK: - Score Updates

    /// Update the score for a match
    /// - Parameters:
    ///   - matchId: The match UUID
    ///   - homeScore: The home team's score
    ///   - awayScore: The away team's score
    func updateScore(matchId: UUID, homeScore: Int, awayScore: Int) async throws {
        let update = ScoreUpdate(
            homeScore: homeScore,
            awayScore: awayScore,
            status: MatchStatus.completed.rawValue,
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        try await client
            .from("matches")
            .update(update)
            .eq("id", value: matchId.uuidString)
            .execute()
    }

    /// Clear the score for a match (revert to scheduled)
    /// - Parameter matchId: The match UUID
    func clearScore(matchId: UUID) async throws {
        let update = ScoreClear(
            status: MatchStatus.scheduled.rawValue,
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        try await client
            .from("matches")
            .update(update)
            .eq("id", value: matchId.uuidString)
            .execute()
    }

    // MARK: - Authentication

    /// Sign in with email and password
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    /// Sign out the current user
    func signOut() async throws {
        try await client.auth.signOut()
    }

    /// Get the currently authenticated Supabase user
    /// - Returns: The Supabase User object or nil
    func currentUser() async throws -> Supabase.User? {
        try await client.auth.user()
    }

    /// Check if a user is currently authenticated
    var isAuthenticated: Bool {
        get async {
            do {
                return try await currentUser() != nil
            } catch {
                return false
            }
        }
    }

    // MARK: - User Profile

    /// Fetch the profile for the current user
    /// - Returns: UserProfile object or nil
    func fetchCurrentUserProfile() async throws -> UserProfile? {
        guard let user = try await currentUser() else { return nil }

        let response: [UserProfile] = try await client
            .from("user_profiles")
            .select("*, houses(name)")
            .eq("id", value: user.id.uuidString)
            .limit(1)
            .execute()
            .value

        return response.first
    }

    /// Fetch a user profile by ID
    /// - Parameter userId: The user's UUID
    /// - Returns: UserProfile object or nil
    func fetchUserProfile(userId: UUID) async throws -> UserProfile? {
        let response: [UserProfile] = try await client
            .from("user_profiles")
            .select("*, houses(name)")
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // MARK: - Locations

    /// Fetch all pitch locations
    /// - Returns: Array of Location objects
    func fetchLocations() async throws -> [Location] {
        let response: [Location] = try await client
            .from("locations")
            .select()
            .order("name", ascending: true)
            .execute()
            .value

        return response
    }
}

// MARK: - Helper Types for Updates

private struct ScoreUpdate: Encodable {
    let homeScore: Int
    let awayScore: Int
    let status: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case homeScore = "home_score"
        case awayScore = "away_score"
        case status
        case updatedAt = "updated_at"
    }
}

private struct ScoreClear: Encodable {
    let status: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case status
        case updatedAt = "updated_at"
    }
}

// MARK: - Error Types

enum SupabaseServiceError: LocalizedError {
    case notAuthenticated
    case insufficientPermissions
    case invalidData
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action."
        case .insufficientPermissions:
            return "You don't have permission to perform this action."
        case .invalidData:
            return "The data received was invalid."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
