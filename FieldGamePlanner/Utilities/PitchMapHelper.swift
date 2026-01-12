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
        let normalized = normalizePitchName(pitch)

        // Check exact match first
        if northFieldsPitches.contains(normalized) {
            return true
        }

        // Check case-insensitive match
        for northPitch in northFieldsPitches {
            if normalized.caseInsensitiveCompare(northPitch) == .orderedSame {
                return true
            }
        }

        // Check if it contains key North Field identifiers
        let lowercased = normalized.lowercased()
        if lowercased.contains("agar") ||
           lowercased.contains("dutchman") ||
           lowercased.contains("austin") ||
           lowercased.contains("o.e. soccer") ||
           lowercased.contains("college field") {
            return true
        }

        return false
    }

    /// Determine if a pitch belongs to South Fields
    static func isSouthFieldsPitch(_ pitchName: String?) -> Bool {
        guard let pitch = pitchName else { return false }
        let normalized = normalizePitchName(pitch)

        // Check exact match first
        if southFieldsPitches.contains(normalized) {
            return true
        }

        // Check case-insensitive match
        for southPitch in southFieldsPitches {
            if normalized.caseInsensitiveCompare(southPitch) == .orderedSame {
                return true
            }
        }

        // Check if it contains key South Field identifiers
        let lowercased = normalized.lowercased()
        if lowercased.contains("south meadow") ||
           lowercased.contains("warre") ||
           lowercased.contains("carter") ||
           lowercased.contains("square close") {
            return true
        }

        return false
    }

    // MARK: - Pitch Matching

    /// Check if two pitch names match (with normalization)
    static func pitchNamesMatch(_ name1: String, _ name2: String) -> Bool {
        let normalized1 = normalizePitchName(name1)
        let normalized2 = normalizePitchName(name2)

        // Exact match (case-insensitive)
        if normalized1.caseInsensitiveCompare(normalized2) == .orderedSame {
            return true
        }

        // Try expanding shortened forms to full names before comparing
        let expanded1 = expandPitchName(normalized1)
        let expanded2 = expandPitchName(normalized2)

        if expanded1.caseInsensitiveCompare(expanded2) == .orderedSame {
            return true
        }

        return false
    }

    /// Find the canonical pitch name from any variant
    static func findCanonicalPitchName(for input: String) -> String? {
        let normalized = normalizePitchName(input)

        // Check North Fields
        for northPitch in northFieldsPitches {
            if pitchNamesMatch(normalized, northPitch) {
                return northPitch
            }
        }

        // Check South Fields
        for southPitch in southFieldsPitches {
            if pitchNamesMatch(normalized, southPitch) {
                return southPitch
            }
        }

        return nil
    }

    // MARK: - Private Helpers

    /// Expand abbreviated pitch names to full names for matching
    /// e.g., "A5" -> "Agar's 5", "D12" -> "Dutchman's 12", "S3" -> "South Meadow 3"
    private static func expandPitchName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        // Try to match abbreviated patterns with exact regex
        // Pattern: letter followed immediately by digits (e.g., "A5", "D12", "S3")
        let pattern = "^([ADSads])(\\d+)$"

        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {

            let letterRange = Range(match.range(at: 1), in: trimmed)!
            let numberRange = Range(match.range(at: 2), in: trimmed)!

            let letter = String(trimmed[letterRange]).uppercased()
            let number = String(trimmed[numberRange])

            switch letter {
            case "A":
                return "Agar's \(number)"
            case "D":
                return "Dutchman's \(number)"
            case "S":
                return "South Meadow \(number)"
            default:
                break
            }
        }

        // If already in full form, return as-is
        return trimmed
    }
}
