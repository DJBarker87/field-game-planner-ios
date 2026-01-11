//
//  MatchResult.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct MatchResult: Identifiable, Codable, Equatable {
    let id: UUID
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int
    let awayScore: Int
    let competition: String
    let date: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var winner: String? {
        if homeScore > awayScore {
            return homeTeam
        } else if awayScore > homeScore {
            return awayTeam
        }
        return nil // Draw
    }

    var isDraw: Bool {
        homeScore == awayScore
    }

    static var preview: MatchResult {
        MatchResult(
            id: UUID(),
            homeTeam: "Keate",
            awayTeam: "Hawtrey",
            homeScore: 3,
            awayScore: 1,
            competition: "Senior League",
            date: Date()
        )
    }
}
