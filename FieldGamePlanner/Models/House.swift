//
//  House.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

/// Represents a house or team in the field game system
struct House: Identifiable, Codable, Equatable, Hashable {
    let id: String  // Housemaster initials (e.g., "JDM", "HWTA") or special team name
    let name: String
    let colours: String  // Path to house crest image (e.g., "/images/houses/angelos.png")
    let createdAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case colours
        case createdAt = "created_at"
    }

    // MARK: - Computed Properties

    /// Path to the house crest image (for bundle loading)
    var crestImagePath: String? {
        // Return the colours field which contains path like "/images/houses/angelos.png"
        guard !colours.isEmpty else { return nil }

        // If it's an image path (starting with / or containing "images"), return it
        if colours.hasPrefix("/") || colours.contains("images") {
            return colours
        }

        // Not an image path (legacy color codes)
        return nil
    }

    /// URL to the house crest image on the server (legacy support for remote loading)
    var crestImageURL: URL? {
        // Assuming colours contains path like "/images/houses/angelos.png"
        guard !colours.isEmpty else { return nil }

        // If it's already a full URL, use it
        if colours.hasPrefix("http") {
            return URL(string: colours)
        }

        // For Supabase Storage paths (starting with /)
        if colours.hasPrefix("/") {
            // Remove leading slash
            let path = String(colours.dropFirst())
            // Construct Supabase Storage URL: /storage/v1/object/public/{bucket}/{path}
            // Assuming "public" bucket (standard Supabase bucket name)
            return URL(string: "\(Config.supabaseURL)/storage/v1/object/public/public/\(path)")
        }

        // Fallback: direct append (for backward compatibility)
        return URL(string: "\(Config.supabaseURL)/\(colours)")
    }

    /// Legacy color parsing for backward compatibility (if colours contains color codes)
    var parsedColours: [Color] {
        // If colours is an image path, return default colors
        if colours.hasPrefix("/") || colours.hasPrefix("http") {
            return [.gray, .white]
        }
        // Otherwise try to parse as color codes
        return KitColorMapper.parse(colours)
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
            id: "JDM",
            name: "Keate",
            colours: "/images/houses/keate.png",
            createdAt: Date()
        )
    }

    static var previewList: [House] {
        [
            House(id: "JDM", name: "Keate", colours: "/images/houses/keate.png", createdAt: Date()),
            House(id: "HWTA", name: "Hawtrey", colours: "/images/houses/hawtrey.png", createdAt: Date()),
            House(id: "IRS", name: "Godolphin", colours: "/images/houses/godolphin.png", createdAt: Date()),
            House(id: "JCAJ", name: "Villiers", colours: "/images/houses/villiers.png", createdAt: Date()),
            House(id: "Field", name: "Field", colours: "/images/houses/field.png", createdAt: Date()),
        ]
    }
}

// MARK: - House Array Extension

extension Array where Element == House {
    /// Find a house by ID (housemaster initials)
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
