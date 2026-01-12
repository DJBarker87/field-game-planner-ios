//
//  LeagueStanding.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

/// Represents a team's standing in a league table
struct LeagueStanding: Identifiable, Codable, Equatable {
    let teamId: UUID
    let teamName: String
    let teamColours: String
    let played: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let goalDifference: Int
    let points: Int

    // Computed id for Identifiable conformance
    var id: UUID { teamId }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case teamId = "team_id"
        case teamName = "team_name"
        case teamColours = "team_colours"
        case played
        case wins
        case draws
        case losses
        case goalsFor = "goals_for"
        case goalsAgainst = "goals_against"
        case goalDifference = "goal_difference"
        case points
    }

    // MARK: - Computed Properties

    /// Parse team colours into SwiftUI Colors
    var parsedColours: [Color] {
        KitColorMapper.parse(teamColours)
    }

    /// Win percentage (0-100)
    var winPercentage: Double {
        guard played > 0 else { return 0 }
        return Double(wins) / Double(played) * 100
    }

    /// Points per game average
    var pointsPerGame: Double {
        guard played > 0 else { return 0 }
        return Double(points) / Double(played)
    }

    /// Goals per game average
    var goalsPerGame: Double {
        guard played > 0 else { return 0 }
        return Double(goalsFor) / Double(played)
    }

    /// Goals conceded per game average
    var goalsConcededPerGame: Double {
        guard played > 0 else { return 0 }
        return Double(goalsAgainst) / Double(played)
    }

    /// Form indicator based on recent results (simplified)
    var formDescription: String {
        if wins > losses * 2 { return "Excellent" }
        if wins > losses { return "Good" }
        if wins == losses { return "Average" }
        return "Poor"
    }

    // MARK: - Equatable

    static func == (lhs: LeagueStanding, rhs: LeagueStanding) -> Bool {
        lhs.teamId == rhs.teamId
    }

    // MARK: - Preview

    static var preview: LeagueStanding {
        LeagueStanding(
            teamId: UUID(),
            teamName: "Keate",
            teamColours: "red/white",
            played: 10,
            wins: 7,
            draws: 2,
            losses: 1,
            goalsFor: 24,
            goalsAgainst: 8,
            goalDifference: 16,
            points: 23
        )
    }

    static var previewList: [LeagueStanding] {
        [
            LeagueStanding(
                teamId: UUID(), teamName: "Keate", teamColours: "red/white",
                played: 10, wins: 7, draws: 2, losses: 1,
                goalsFor: 24, goalsAgainst: 8, goalDifference: 16, points: 23
            ),
            LeagueStanding(
                teamId: UUID(), teamName: "Hawtrey", teamColours: "navy/gold",
                played: 10, wins: 6, draws: 3, losses: 1,
                goalsFor: 20, goalsAgainst: 10, goalDifference: 10, points: 21
            ),
            LeagueStanding(
                teamId: UUID(), teamName: "Godolphin", teamColours: "maroon/sky",
                played: 10, wins: 5, draws: 3, losses: 2,
                goalsFor: 18, goalsAgainst: 12, goalDifference: 6, points: 18
            ),
        ]
    }
}

// MARK: - Import SwiftUI for Color

import SwiftUI

// MARK: - Array Extensions

extension Array where Element == LeagueStanding {
    /// Sort by points, then goal difference
    var sortedByPosition: [LeagueStanding] {
        sorted { lhs, rhs in
            if lhs.points != rhs.points {
                return lhs.points > rhs.points
            }
            return lhs.goalDifference > rhs.goalDifference
        }
    }

    /// Get standing for a specific team
    func standing(for teamId: UUID) -> LeagueStanding? {
        first { $0.teamId == teamId }
    }
}
