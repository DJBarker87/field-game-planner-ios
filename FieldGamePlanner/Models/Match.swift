//
//  Match.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

// MARK: - Base Match Model

/// Base match model representing the core match data
struct Match: Identifiable, Codable, Equatable {
    let id: UUID
    let homeTeamId: UUID
    let awayTeamId: UUID
    let competitionType: String
    let matchDate: Date
    let matchTime: String?
    let locationId: UUID?
    let homeScore: Int?
    let awayScore: Int?
    let status: MatchStatus
    let createdAt: Date?
    let updatedAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case homeTeamId = "home_team_id"
        case awayTeamId = "away_team_id"
        case competitionType = "competition_type"
        case matchDate = "match_date"
        case matchTime = "match_time"
        case locationId = "location_id"
        case homeScore = "home_score"
        case awayScore = "away_score"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - Computed Properties

    var isCompleted: Bool {
        status == .completed && homeScore != nil && awayScore != nil
    }

    var isUpcoming: Bool {
        status == .scheduled && matchDate >= Date()
    }

    var scoreString: String? {
        guard let home = homeScore, let away = awayScore else { return nil }
        return "\(home) - \(away)"
    }

    // MARK: - Equatable

    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Preview

    static var preview: Match {
        Match(
            id: UUID(),
            homeTeamId: UUID(),
            awayTeamId: UUID(),
            competitionType: "Senior League",
            matchDate: Date(),
            matchTime: "14:30",
            locationId: nil,
            homeScore: nil,
            awayScore: nil,
            status: .scheduled,
            createdAt: Date(),
            updatedAt: nil
        )
    }
}

// MARK: - Match With Houses

/// Extended match model with resolved team names and colours from the database view
struct MatchWithHouses: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let time: String?
    let competitionType: String
    let pitch: String?
    let homeTeamId: UUID
    let awayTeamId: UUID
    let homeTeamName: String
    let awayTeamName: String
    let homeTeamColours: String
    let awayTeamColours: String
    let umpires: String?
    let status: String
    let homeScore: Int?
    let awayScore: Int?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case time
        case competitionType = "competition_type"
        case pitch
        case homeTeamId = "home_team_id"
        case awayTeamId = "away_team_id"
        case homeTeamName = "home_team_name"
        case awayTeamName = "away_team_name"
        case homeTeamColours = "home_team_colours"
        case awayTeamColours = "away_team_colours"
        case umpires
        case status
        case homeScore = "home_score"
        case awayScore = "away_score"
    }

    // MARK: - Computed Properties

    /// Parse home team colours into SwiftUI Colors
    var homeKitColors: [Color] {
        KitColorMapper.parse(homeTeamColours)
    }

    /// Parse away team colours into SwiftUI Colors
    var awayKitColors: [Color] {
        KitColorMapper.parse(awayTeamColours)
    }

    /// Competition color based on type
    var competitionColor: Color {
        Color.competitionColor(for: competitionType)
    }

    /// Formatted date string
    var formattedDate: String {
        date.displayString
    }

    /// Formatted time string
    var formattedTime: String {
        guard let time = time else { return "TBD" }
        // Convert 24h to 12h format if needed
        if let parsedDate = DateFormatter.timeOnly.date(from: time) {
            return DateFormatter.displayTime.string(from: parsedDate)
        }
        return time
    }

    /// Full location string
    var fullLocationString: String? {
        pitch
    }

    var isCompleted: Bool {
        status == "completed" && homeScore != nil && awayScore != nil
    }

    var isUpcoming: Bool {
        status == "scheduled"
    }

    var scoreString: String? {
        guard let home = homeScore, let away = awayScore else { return nil }
        return "\(home) - \(away)"
    }

    /// Determine the winner
    var winner: String? {
        guard let home = homeScore, let away = awayScore else { return nil }
        if home > away { return homeTeamName }
        if away > home { return awayTeamName }
        return nil // Draw
    }

    var isDraw: Bool {
        guard let home = homeScore, let away = awayScore else { return false }
        return home == away
    }

    // MARK: - Methods

    /// Check if a given team is involved in this match
    func involves(teamId: UUID) -> Bool {
        homeTeamId == teamId || awayTeamId == teamId
    }

    /// Check if a given team name is involved in this match
    func involves(teamName: String) -> Bool {
        homeTeamName.lowercased() == teamName.lowercased() ||
        awayTeamName.lowercased() == teamName.lowercased()
    }

    // MARK: - Equatable

    static func == (lhs: MatchWithHouses, rhs: MatchWithHouses) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Preview

    static var preview: MatchWithHouses {
        MatchWithHouses(
            id: UUID(),
            date: Date(),
            time: "14:30",
            competitionType: "Senior League",
            pitch: "North Fields - Pitch 3",
            homeTeamId: UUID(),
            awayTeamId: UUID(),
            homeTeamName: "Keate",
            awayTeamName: "Hawtrey",
            homeTeamColours: "red/white",
            awayTeamColours: "navy/gold",
            umpires: nil,
            status: "scheduled",
            homeScore: nil,
            awayScore: nil
        )
    }

    static var completedPreview: MatchWithHouses {
        MatchWithHouses(
            id: UUID(),
            date: Date().addingTimeInterval(-86400),
            time: "14:30",
            competitionType: "Senior League",
            pitch: "North Fields - Pitch 3",
            homeTeamId: UUID(),
            awayTeamId: UUID(),
            homeTeamName: "Keate",
            awayTeamName: "Hawtrey",
            homeTeamColours: "red/white",
            awayTeamColours: "navy/gold",
            umpires: nil,
            status: "completed",
            homeScore: 3,
            awayScore: 1
        )
    }
}

// MARK: - Date Formatter Helpers

private extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

// MARK: - Array Extensions

extension Array where Element == MatchWithHouses {
    /// Filter matches by team
    func matches(for teamId: UUID) -> [MatchWithHouses] {
        filter { $0.involves(teamId: teamId) }
    }

    /// Filter matches by competition
    func matches(for competition: String) -> [MatchWithHouses] {
        filter { $0.competitionType == competition }
    }

    /// Filter matches within date range
    func matches(from start: Date, to end: Date) -> [MatchWithHouses] {
        filter { $0.date >= start && $0.date <= end }
    }

    /// Get only upcoming matches
    var upcoming: [MatchWithHouses] {
        filter { $0.isUpcoming }
    }

    /// Get only completed matches
    var completed: [MatchWithHouses] {
        filter { $0.isCompleted }
    }

    /// Sort by date (ascending)
    var sortedByDate: [MatchWithHouses] {
        sorted { $0.date < $1.date }
    }

    /// Group by date
    var groupedByDate: [Date: [MatchWithHouses]] {
        Dictionary(grouping: self) { match in
            Calendar.current.startOfDay(for: match.date)
        }
    }

    /// Group by competition
    var groupedByCompetition: [String: [MatchWithHouses]] {
        Dictionary(grouping: self) { $0.competitionType }
    }
}
