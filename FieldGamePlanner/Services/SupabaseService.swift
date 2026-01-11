//
//  SupabaseService.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation
import Supabase

actor SupabaseService {
    static let shared = SupabaseService()

    private let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
    }

    // MARK: - Fixtures

    func fetchUpcomingMatches() async throws -> [Match] {
        let response: [Match] = try await client
            .from("upcoming_matches")
            .select()
            .order("date", ascending: true)
            .execute()
            .value

        return response
    }

    // MARK: - Results

    func fetchRecentResults() async throws -> [MatchResult] {
        let response: [MatchResult] = try await client
            .from("recent_results")
            .select()
            .order("date", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Standings

    func fetchStandings() async throws -> [Standing] {
        let response: [Standing] = try await client
            .from("league_standings")
            .select()
            .execute()
            .value

        return response
    }

    // MARK: - Houses

    func fetchHouses() async throws -> [House] {
        let response: [House] = try await client
            .from("houses")
            .select()
            .order("name", ascending: true)
            .execute()
            .value

        return response
    }

    // MARK: - Authentication

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func currentUser() async throws -> Supabase.User? {
        try await client.auth.user()
    }

    var isAuthenticated: Bool {
        get async {
            do {
                return try await currentUser() != nil
            } catch {
                return false
            }
        }
    }
}
