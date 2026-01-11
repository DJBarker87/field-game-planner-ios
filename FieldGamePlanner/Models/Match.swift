//
//  Match.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct Match: Identifiable, Codable, Equatable {
    let id: UUID
    let homeTeam: String
    let awayTeam: String
    let homeKitColors: [Color]
    let awayKitColors: [Color]
    let competition: String
    let date: Date
    let time: String
    let pitch: String?
    let locationId: UUID?

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Custom coding for Color arrays
    enum CodingKeys: String, CodingKey {
        case id, homeTeam, awayTeam, competition, date, time, pitch, locationId
        case homeKitColorsRaw = "homeKitColors"
        case awayKitColorsRaw = "awayKitColors"
    }

    init(
        id: UUID = UUID(),
        homeTeam: String,
        awayTeam: String,
        homeKitColors: [Color],
        awayKitColors: [Color],
        competition: String,
        date: Date,
        time: String,
        pitch: String? = nil,
        locationId: UUID? = nil
    ) {
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeKitColors = homeKitColors
        self.awayKitColors = awayKitColors
        self.competition = competition
        self.date = date
        self.time = time
        self.pitch = pitch
        self.locationId = locationId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        homeTeam = try container.decode(String.self, forKey: .homeTeam)
        awayTeam = try container.decode(String.self, forKey: .awayTeam)
        competition = try container.decode(String.self, forKey: .competition)
        date = try container.decode(Date.self, forKey: .date)
        time = try container.decode(String.self, forKey: .time)
        pitch = try container.decodeIfPresent(String.self, forKey: .pitch)
        locationId = try container.decodeIfPresent(UUID.self, forKey: .locationId)

        let homeColorsRaw = try container.decodeIfPresent(String.self, forKey: .homeKitColorsRaw) ?? ""
        let awayColorsRaw = try container.decodeIfPresent(String.self, forKey: .awayKitColorsRaw) ?? ""
        homeKitColors = KitColorMapper.parse(homeColorsRaw)
        awayKitColors = KitColorMapper.parse(awayColorsRaw)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(homeTeam, forKey: .homeTeam)
        try container.encode(awayTeam, forKey: .awayTeam)
        try container.encode(competition, forKey: .competition)
        try container.encode(date, forKey: .date)
        try container.encode(time, forKey: .time)
        try container.encodeIfPresent(pitch, forKey: .pitch)
        try container.encodeIfPresent(locationId, forKey: .locationId)
    }

    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id
    }

    static var preview: Match {
        Match(
            id: UUID(),
            homeTeam: "Keate",
            awayTeam: "Hawtrey",
            homeKitColors: [.red, .white],
            awayKitColors: [.blue, .blue],
            competition: "Senior League",
            date: Date(),
            time: "2:30 PM",
            pitch: "Field 1"
        )
    }
}
