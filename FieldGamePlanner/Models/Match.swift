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
    let id: String
    let homeTeamId: String
    let awayTeamId: String
    let competitionType: String
    let matchDate: Date
    let matchTime: String?
    let locationId: String?
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
            id: "1",
            homeTeamId: "1",
            awayTeamId: "2",
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
    let id: String
    let date: Date
    let time: String?
    let competitionType: String
    let pitch: String?
    let homeTeamId: String
    let awayTeamId: String?
    let homeTeamName: String
    let awayTeamName: String?
    let homeTeamColours: String?
    let awayTeamColours: String?
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

    // MARK: - Custom Decoding

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        time = try container.decodeIfPresent(String.self, forKey: .time)
        competitionType = try container.decode(String.self, forKey: .competitionType)
        pitch = try container.decodeIfPresent(String.self, forKey: .pitch)
        homeTeamId = try container.decode(String.self, forKey: .homeTeamId)
        awayTeamId = try container.decodeIfPresent(String.self, forKey: .awayTeamId)
        homeTeamName = try container.decode(String.self, forKey: .homeTeamName)
        awayTeamName = try container.decodeIfPresent(String.self, forKey: .awayTeamName)
        homeTeamColours = try container.decodeIfPresent(String.self, forKey: .homeTeamColours)
        awayTeamColours = try container.decodeIfPresent(String.self, forKey: .awayTeamColours)
        umpires = try container.decodeIfPresent(String.self, forKey: .umpires)
        status = try container.decode(String.self, forKey: .status)
        homeScore = try container.decodeIfPresent(Int.self, forKey: .homeScore)
        awayScore = try container.decodeIfPresent(Int.self, forKey: .awayScore)

        // Custom date parsing - handle "YYYY-MM-DD" format from database
        let dateString = try container.decode(String.self, forKey: .date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        if let parsedDate = dateFormatter.date(from: dateString) {
            date = parsedDate
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [CodingKeys.date],
                    debugDescription: "Invalid date format: \(dateString)"
                )
            )
        }
    }

    // MARK: - Memberwise Init (for previews)

    init(
        id: String,
        date: Date,
        time: String?,
        competitionType: String,
        pitch: String?,
        homeTeamId: String,
        awayTeamId: String?,
        homeTeamName: String,
        awayTeamName: String?,
        homeTeamColours: String?,
        awayTeamColours: String?,
        umpires: String?,
        status: String,
        homeScore: Int?,
        awayScore: Int?
    ) {
        self.id = id
        self.date = date
        self.time = time
        self.competitionType = competitionType
        self.pitch = pitch
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.homeTeamColours = homeTeamColours
        self.awayTeamColours = awayTeamColours
        self.umpires = umpires
        self.status = status
        self.homeScore = homeScore
        self.awayScore = awayScore
    }

    // MARK: - Computed Properties

    /// Parse home team colours into SwiftUI Colors
    var homeKitColors: [Color] {
        KitColorMapper.parse(homeTeamColours ?? "")
    }

    /// Parse away team colours into SwiftUI Colors
    var awayKitColors: [Color] {
        KitColorMapper.parse(awayTeamColours ?? "")
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
    func involves(teamId: String) -> Bool {
        homeTeamId == teamId || awayTeamId == teamId
    }

    /// Check if a given team is involved in this match (String ID version - alias)
    func involves(teamIdString: String) -> Bool {
        involves(teamId: teamIdString)
    }

    /// Check if a given team name is involved in this match
    func involves(teamName: String) -> Bool {
        homeTeamName.lowercased() == teamName.lowercased() ||
        (awayTeamName?.lowercased() == teamName.lowercased())
    }

    // MARK: - Equatable

    static func == (lhs: MatchWithHouses, rhs: MatchWithHouses) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Preview

    static var preview: MatchWithHouses {
        MatchWithHouses(
            id: "1",
            date: Date(),
            time: "14:30",
            competitionType: "Senior League",
            pitch: "North Fields - Pitch 3",
            homeTeamId: "1",
            awayTeamId: "2",
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
            id: "2",
            date: Date().addingTimeInterval(-86400),
            time: "14:30",
            competitionType: "Senior League",
            pitch: "North Fields - Pitch 3",
            homeTeamId: "1",
            awayTeamId: "2",
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
    /// Filter matches by team ID
    func matchesForTeam(_ teamId: String) -> [MatchWithHouses] {
        filter { $0.involves(teamId: teamId) }
    }

    /// Filter matches by competition type
    func matchesForCompetition(_ competition: String) -> [MatchWithHouses] {
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
