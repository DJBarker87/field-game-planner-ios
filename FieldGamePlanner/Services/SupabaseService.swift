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

    /// Fetch a single house by ID
    /// - Parameter id: The house UUID
    /// - Returns: The House object or nil if not found
    func fetchHouse(id: UUID) async throws -> House? {
        let response: [House] = try await client
            .from("houses")
            .select()
            .eq("id", value: id.uuidString)
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
    ///   - teamId: Optional team ID to filter matches involving this team
    /// - Returns: Array of MatchWithHouses objects
    func fetchUpcomingMatches(
        startDate: Date? = nil,
        endDate: Date? = nil,
        teamId: UUID? = nil
    ) async throws -> [MatchWithHouses] {
        var query = client
            .from("upcoming_matches")
            .select()

        // Apply date filters
        if let start = startDate {
            let dateString = ISO8601DateFormatter().string(from: start)
            query = query.gte("match_date", value: dateString)
        }

        if let end = endDate {
            let dateString = ISO8601DateFormatter().string(from: end)
            query = query.lte("match_date", value: dateString)
        }

        // Apply team filter (matches where team is home OR away)
        if let team = teamId {
            query = query.or("home_team_id.eq.\(team.uuidString),away_team_id.eq.\(team.uuidString)")
        }

        let response: [MatchWithHouses] = try await query
            .order("match_date", ascending: true)
            .order("match_time", ascending: true)
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
    ///   - teamId: Optional team ID to filter
    ///   - year: Optional year to filter (defaults to current year)
    ///   - limit: Maximum number of results to return
    /// - Returns: Array of MatchWithHouses objects (completed matches)
    func fetchRecentResults(
        teamId: UUID? = nil,
        year: Int? = nil,
        limit: Int = 50
    ) async throws -> [MatchWithHouses] {
        var query = client
            .from("recent_results")
            .select()

        // Filter to current calendar year by default
        let targetYear = year ?? Calendar.current.component(.year, from: Date())
        let startOfYear = Calendar.current.date(from: DateComponents(year: targetYear, month: 1, day: 1))!
        let endOfYear = Calendar.current.date(from: DateComponents(year: targetYear + 1, month: 1, day: 1))!

        let startString = ISO8601DateFormatter().string(from: startOfYear)
        let endString = ISO8601DateFormatter().string(from: endOfYear)

        query = query
            .gte("match_date", value: startString)
            .lt("match_date", value: endString)

        // Apply team filter
        if let team = teamId {
            query = query.or("home_team_id.eq.\(team.uuidString),away_team_id.eq.\(team.uuidString)")
        }

        let response: [MatchWithHouses] = try await query
            .order("match_date", ascending: false)
            .limit(limit)
            .execute()
            .value

        return response
    }

    // MARK: - League Standings

    /// Fetch league standings with optional competition filter
    /// - Parameter competitionType: Optional competition type to filter
    /// - Returns: Array of LeagueStanding objects
    func fetchStandings(competitionType: String? = nil) async throws -> [LeagueStanding] {
        var query = client
            .from("league_standings")
            .select()

        if let competition = competitionType {
            query = query.eq("competition_type", value: competition)
        }

        let response: [LeagueStanding] = try await query
            .order("competition_type", ascending: true)
            .order("position", ascending: true)
            .execute()
            .value

        return response
    }

    /// Fetch standings for a specific team across all competitions
    /// - Parameter teamId: The team UUID
    /// - Returns: Array of LeagueStanding objects for that team
    func fetchStandings(for teamId: UUID) async throws -> [LeagueStanding] {
        let response: [LeagueStanding] = try await client
            .from("league_standings")
            .select()
            .eq("team_id", value: teamId.uuidString)
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
        try await client
            .from("matches")
            .update([
                "home_score": homeScore,
                "away_score": awayScore,
                "status": MatchStatus.completed.rawValue,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .eq("id", value: matchId.uuidString)
            .execute()
    }

    /// Clear the score for a match (revert to scheduled)
    /// - Parameter matchId: The match UUID
    func clearScore(matchId: UUID) async throws {
        try await client
            .from("matches")
            .update([
                "home_score": NSNull(),
                "away_score": NSNull(),
                "status": MatchStatus.scheduled.rawValue,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
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
    /// - Returns: Array of location dictionaries
    func fetchLocations() async throws -> [[String: Any]] {
        let response: [[String: Any]] = try await client
            .from("locations")
            .select()
            .order("name", ascending: true)
            .execute()
            .value

        return response
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
