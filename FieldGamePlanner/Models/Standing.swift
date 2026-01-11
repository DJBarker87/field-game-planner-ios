//
//  Standing.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

struct Standing: Identifiable, Codable, Equatable {
    let id: UUID
    let teamName: String
    let competition: String
    let position: Int
    let played: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let points: Int

    var goalDifference: Int {
        goalsFor - goalsAgainst
    }

    static var preview: Standing {
        Standing(
            id: UUID(),
            teamName: "Keate",
            competition: "Senior League",
            position: 1,
            played: 10,
            wins: 8,
            draws: 1,
            losses: 1,
            goalsFor: 24,
            goalsAgainst: 8,
            points: 25
        )
    }
}
