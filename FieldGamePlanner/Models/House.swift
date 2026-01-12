//
//  House.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

/// Represents a house or team in the field game system
struct House: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let colours: String?
    let createdAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case colours
        case createdAt = "created_at"
    }

    // MARK: - Computed Properties

    /// Parse the colour string into SwiftUI Colors
    var parsedColours: [Color] {
        KitColorMapper.parse(colours ?? "")
    }

    /// Check if this is a school team (e.g., "Field", "1st Field", "2nd XI")
    /// Uses regex to match patterns like "Field", "1st Field", "2nd Field", "1st XI", etc.
    var isSchoolTeam: Bool {
        let patterns = [
            "^Field$",                          // Exact "Field"
            "^\\d+(st|nd|rd|th)?\\s*Field$",   // "1st Field", "2nd Field", etc.
            "^\\d+(st|nd|rd|th)?\\s*XI$",      // "1st XI", "2nd XI", etc.
            "^School\\b",                       // Starts with "School"
            "^College\\b",                      // Starts with "College"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(name.startIndex..., in: name)
                if regex.firstMatch(in: name, options: [], range: range) != nil {
                    return true
                }
            }
        }
        return false
    }

    /// Short name for display in compact views
    var shortName: String {
        // Return first 2-3 characters or abbreviation
        if name.count <= 3 {
            return name
        }

        // Common abbreviations
        let abbreviations: [String: String] = [
            "Angelo's": "ANG",
            "Baldwin's Bec": "BB",
            "Caxton": "CAX",
            "Coleridge": "COL",
            "Cotton Hall": "CH",
            "Durnford": "DUR",
            "Evans'": "EVA",
            "Godolphin": "GOD",
            "Hawtrey": "HAW",
            "Hopgarden": "HOP",
            "Keate": "KEA",
            "Villiers": "VIL",
            "Warre": "WAR",
            "Weston's": "WES",
            "Wotton": "WOT",
        ]

        return abbreviations[name] ?? String(name.prefix(3)).uppercased()
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Preview

    static var preview: House {
        House(
            id: "1",
            name: "Keate",
            colours: "red/white",
            createdAt: Date()
        )
    }

    static var previewList: [House] {
        [
            House(id: "1", name: "Keate", colours: "red/white", createdAt: Date()),
            House(id: "2", name: "Hawtrey", colours: "navy/gold", createdAt: Date()),
            House(id: "3", name: "Godolphin", colours: "maroon/sky", createdAt: Date()),
            House(id: "4", name: "Villiers", colours: "green/white", createdAt: Date()),
            House(id: "5", name: "Field", colours: "eton/white", createdAt: Date()),
        ]
    }
}

// MARK: - House Array Extension

extension Array where Element == House {
    /// Find a house by ID
    func house(withId id: String) -> House? {
        first { $0.id == id }
    }

    /// Filter to only school teams
    var schoolTeams: [House] {
        filter { $0.isSchoolTeam }
    }

    /// Filter to only house teams (non-school)
    var houseTeams: [House] {
        filter { !$0.isSchoolTeam }
    }

    /// Sort alphabetically by name
    var sortedByName: [House] {
        sorted { $0.name < $1.name }
    }
}
