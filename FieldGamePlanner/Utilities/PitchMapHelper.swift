//
//  PitchMapHelper.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import Foundation

/// Helper for pitch map operations including name normalization and map detection
struct PitchMapHelper {

    // MARK: - North Fields Pitches

    static let northFieldsPitches: Set<String> = [
        // Agar's Plough
        "Agar's 1", "Agar's 2", "Agar's 3", "Agar's 4", "Agar's 5", "Agar's 6", "Agar's 7",
        // Dutchman's
        "Dutchman's 1", "Dutchman's 2", "Dutchman's 3", "Dutchman's 4",
        "Dutchman's 5", "Dutchman's 6", "Dutchman's 7", "Dutchman's 8",
        "Dutchman's 9", "Dutchman's 10", "Dutchman's 11", "Dutchman's 12",
        "Dutchman's 13", "Dutchman's 14", "Dutchman's 15",
        // Other North pitches
        "Austin's", "O.E. Soccer", "College Field"
    ]

    // MARK: - South Fields Pitches

    static let southFieldsPitches: Set<String> = [
        // South Meadow
        "South Meadow 1", "South Meadow 2", "South Meadow 3", "South Meadow 4", "South Meadow 5",
        // Individual pitches
        "Warre's", "Carter's", "Square Close"
    ]

    // MARK: - Pitch Name Normalization

    /// Normalize a pitch name to handle apostrophe variants and common typos
    static func normalizePitchName(_ name: String) -> String {
        return name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "'", with: "'")  // Curly apostrophe to straight
            .replacingOccurrences(of: "'", with: "'")  // Another curly variant
            .replacingOccurrences(of: "`", with: "'")  // Backtick to apostrophe
            .replacingOccurrences(of: "Dutchmna's", with: "Dutchman's", options: .caseInsensitive)  // Common typo
            .replacingOccurrences(of: "  ", with: " ")  // Double spaces
    }

    // MARK: - Map Detection

    /// Determine if a pitch belongs to North Fields
    static func isNorthFieldsPitch(_ pitchName: String?) -> Bool {
        guard let pitch = pitchName else { return false }
        let normalized = normalizePitchName(pitch).lowercased()

        // Check if it contains key North Field identifiers
        return normalized.contains("agar") ||
               normalized.contains("dutchman") ||
               normalized.contains("austin") ||
               normalized.contains("o.e. soccer") ||
               normalized.contains("college field")
    }

    /// Determine if a pitch belongs to South Fields
    static func isSouthFieldsPitch(_ pitchName: String?) -> Bool {
        guard let pitch = pitchName else { return false }
        let normalized = normalizePitchName(pitch).lowercased()

        // Check if it contains key South Field identifiers
        return normalized.contains("south meadow") ||
               normalized.contains("warre") ||
               normalized.contains("carter") ||
               normalized.contains("square close")
    }

    // MARK: - Pitch Matching

    /// Check if two pitch names match - EXACT MATCH ONLY after normalization
    static func pitchNamesMatch(_ name1: String, _ name2: String) -> Bool {
        // Normalize both names
        let normalized1 = normalizePitchName(name1).lowercased()
        let normalized2 = normalizePitchName(name2).lowercased()

        // Direct exact match
        if normalized1 == normalized2 {
            return true
        }

        // Try to canonicalize both to their full standard forms
        let canonical1 = getCanonicalName(normalized1)
        let canonical2 = getCanonicalName(normalized2)

        return canonical1 == canonical2
    }

    /// Find the canonical pitch name from any variant
    static func findCanonicalPitchName(for input: String) -> String? {
        let canonical = getCanonicalName(normalizePitchName(input).lowercased())

        // Find in north fields
        for northPitch in northFieldsPitches {
            if getCanonicalName(northPitch.lowercased()) == canonical {
                return northPitch
            }
        }

        // Find in south fields
        for southPitch in southFieldsPitches {
            if getCanonicalName(southPitch.lowercased()) == canonical {
                return southPitch
            }
        }

        return nil
    }

    // MARK: - Private Helpers

    /// Get the canonical name for a pitch (handles abbreviations)
    /// Returns the name in lowercase standardized format for exact matching
    private static func getCanonicalName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        // Check exact matches in our pitch lists first (case-insensitive)
        for pitch in northFieldsPitches {
            if pitch.lowercased() == trimmed {
                return pitch.lowercased()
            }
        }
        for pitch in southFieldsPitches {
            if pitch.lowercased() == trimmed {
                return pitch.lowercased()
            }
        }

        // Handle specific abbreviation patterns explicitly
        // Agar's pitches
        if trimmed == "a1" { return "agar's 1" }
        if trimmed == "a2" { return "agar's 2" }
        if trimmed == "a3" { return "agar's 3" }
        if trimmed == "a4" { return "agar's 4" }
        if trimmed == "a5" { return "agar's 5" }
        if trimmed == "a6" { return "agar's 6" }
        if trimmed == "a7" { return "agar's 7" }

        // Dutchman's pitches
        if trimmed == "d1" { return "dutchman's 1" }
        if trimmed == "d2" { return "dutchman's 2" }
        if trimmed == "d3" { return "dutchman's 3" }
        if trimmed == "d4" { return "dutchman's 4" }
        if trimmed == "d5" { return "dutchman's 5" }
        if trimmed == "d6" { return "dutchman's 6" }
        if trimmed == "d7" { return "dutchman's 7" }
        if trimmed == "d8" { return "dutchman's 8" }
        if trimmed == "d9" { return "dutchman's 9" }
        if trimmed == "d10" { return "dutchman's 10" }
        if trimmed == "d11" { return "dutchman's 11" }
        if trimmed == "d12" { return "dutchman's 12" }
        if trimmed == "d13" { return "dutchman's 13" }
        if trimmed == "d14" { return "dutchman's 14" }
        if trimmed == "d15" { return "dutchman's 15" }

        // South Meadow pitches
        if trimmed == "s1" { return "south meadow 1" }
        if trimmed == "s2" { return "south meadow 2" }
        if trimmed == "s3" { return "south meadow 3" }
        if trimmed == "s4" { return "south meadow 4" }
        if trimmed == "s5" { return "south meadow 5" }

        // Return as-is if no abbreviation matched
        return trimmed
    }
}
