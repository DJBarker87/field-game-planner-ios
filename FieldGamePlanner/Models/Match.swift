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
    let homeTeamId: UUID
    let awayTeamId: UUID
    let homeTeamName: String
    let awayTeamName: String
    let homeTeamColours: String
    let awayTeamColours: String
    let competitionType: String
    let matchDate: Date
    let matchTime: String?
    let locationId: UUID?
    let locationName: String?
    let pitchName: String?
    let homeScore: Int?
    let awayScore: Int?
    let status: MatchStatus

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case homeTeamId = "home_team_id"
        case awayTeamId = "away_team_id"
        case homeTeamName = "home_team_name"
        case awayTeamName = "away_team_name"
        case homeTeamColours = "home_team_colours"
        case awayTeamColours = "away_team_colours"
        case competitionType = "competition_type"
        case matchDate = "match_date"
        case matchTime = "match_time"
        case locationId = "location_id"
        case locationName = "location_name"
        case pitchName = "pitch_name"
        case homeScore = "home_score"
        case awayScore = "away_score"
        case status
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
        matchDate.displayString
    }

    /// Formatted time string
    var formattedTime: String {
        guard let time = matchTime else { return "TBD" }
        // Convert 24h to 12h format if needed
        if let date = DateFormatter.timeOnly.date(from: time) {
            return DateFormatter.displayTime.string(from: date)
        }
        return time
    }

    /// Full location string (e.g., "North Fields - Pitch 3")
    var fullLocationString: String? {
        if let location = locationName, let pitch = pitchName {
            return "\(location) - \(pitch)"
        }
        return locationName ?? pitchName
    }

    var isCompleted: Bool {
        status == .completed && homeScore != nil && awayScore != nil
    }

    var isUpcoming: Bool {
        status == .scheduled
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
            homeTeamId: UUID(),
            awayTeamId: UUID(),
            homeTeamName: "Keate",
            awayTeamName: "Hawtrey",
            homeTeamColours: "red/white",
            awayTeamColours: "navy/gold",
            competitionType: "Senior League",
            matchDate: Date(),
            matchTime: "14:30",
            locationId: UUID(),
            locationName: "North Fields",
            pitchName: "Pitch 3",
            homeScore: nil,
            awayScore: nil,
            status: .scheduled
        )
    }

    static var completedPreview: MatchWithHouses {
        MatchWithHouses(
            id: UUID(),
            homeTeamId: UUID(),
            awayTeamId: UUID(),
            homeTeamName: "Keate",
            awayTeamName: "Hawtrey",
            homeTeamColours: "red/white",
            awayTeamColours: "navy/gold",
            competitionType: "Senior League",
            matchDate: Date().addingTimeInterval(-86400),
            matchTime: "14:30",
            locationId: UUID(),
            locationName: "North Fields",
            pitchName: "Pitch 3",
            homeScore: 3,
            awayScore: 1,
            status: .completed
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
        filter { $0.matchDate >= start && $0.matchDate <= end }
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
        sorted { $0.matchDate < $1.matchDate }
    }

    /// Group by date
    var groupedByDate: [Date: [MatchWithHouses]] {
        Dictionary(grouping: self) { match in
            Calendar.current.startOfDay(for: match.matchDate)
        }
    }

    /// Group by competition
    var groupedByCompetition: [String: [MatchWithHouses]] {
        Dictionary(grouping: self) { $0.competitionType }
    }
}
