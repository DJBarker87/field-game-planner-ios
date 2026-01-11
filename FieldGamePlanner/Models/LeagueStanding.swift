//
//  LeagueStanding.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

/// Represents a team's standing in a league table
struct LeagueStanding: Identifiable, Codable, Equatable {
    let id: UUID
    let teamId: UUID
    let teamName: String
    let teamColours: String
    let competitionType: String
    let played: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let goalDifference: Int
    let points: Int
    let position: Int?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case teamName = "team_name"
        case teamColours = "team_colours"
        case competitionType = "competition_type"
        case played
        case wins
        case draws
        case losses
        case goalsFor = "goals_for"
        case goalsAgainst = "goals_against"
        case goalDifference = "goal_difference"
        case points
        case position
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
        lhs.id == rhs.id
    }

    // MARK: - Preview

    static var preview: LeagueStanding {
        LeagueStanding(
            id: UUID(),
            teamId: UUID(),
            teamName: "Keate",
            teamColours: "red/white",
            competitionType: "Senior League",
            played: 10,
            wins: 7,
            draws: 2,
            losses: 1,
            goalsFor: 24,
            goalsAgainst: 8,
            goalDifference: 16,
            points: 23,
            position: 1
        )
    }

    static var previewList: [LeagueStanding] {
        [
            LeagueStanding(
                id: UUID(), teamId: UUID(), teamName: "Keate", teamColours: "red/white",
                competitionType: "Senior League", played: 10, wins: 7, draws: 2, losses: 1,
                goalsFor: 24, goalsAgainst: 8, goalDifference: 16, points: 23, position: 1
            ),
            LeagueStanding(
                id: UUID(), teamId: UUID(), teamName: "Hawtrey", teamColours: "navy/gold",
                competitionType: "Senior League", played: 10, wins: 6, draws: 3, losses: 1,
                goalsFor: 20, goalsAgainst: 10, goalDifference: 10, points: 21, position: 2
            ),
            LeagueStanding(
                id: UUID(), teamId: UUID(), teamName: "Godolphin", teamColours: "maroon/sky",
                competitionType: "Senior League", played: 10, wins: 5, draws: 3, losses: 2,
                goalsFor: 18, goalsAgainst: 12, goalDifference: 6, points: 18, position: 3
            ),
        ]
    }
}

// MARK: - Import SwiftUI for Color

import SwiftUI

// MARK: - Array Extensions

extension Array where Element == LeagueStanding {
    /// Sort by position (or points if position is nil)
    var sortedByPosition: [LeagueStanding] {
        sorted { lhs, rhs in
            if let lhsPos = lhs.position, let rhsPos = rhs.position {
                return lhsPos < rhsPos
            }
            // Fall back to points, then goal difference
            if lhs.points != rhs.points {
                return lhs.points > rhs.points
            }
            return lhs.goalDifference > rhs.goalDifference
        }
    }

    /// Group by competition type
    var groupedByCompetition: [String: [LeagueStanding]] {
        Dictionary(grouping: self) { $0.competitionType }
    }

    /// Filter by competition
    func standings(for competition: String) -> [LeagueStanding] {
        filter { $0.competitionType == competition }.sortedByPosition
    }

    /// Get standing for a specific team
    func standing(for teamId: UUID) -> LeagueStanding? {
        first { $0.teamId == teamId }
    }
}
