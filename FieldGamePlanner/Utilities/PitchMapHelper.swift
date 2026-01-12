//
//  PitchMapHelper.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import Foundation

/// Helper for pitch map operations including name normalization and map detection
struct PitchMapHelper {

    // MARK: - Pitch Type & Number

    private enum PitchType: Equatable {
        case agars(Int)
        case dutchmans(Int)
        case austins
        case oeSoccer
        case collegeField
        case southMeadow(Int)
        case warres
        case carters
        case squareClose
        case unknown(String)
    }

    // MARK: - Map Detection

    /// Determine if a pitch belongs to North Fields
    static func isNorthFieldsPitch(_ pitchName: String?) -> Bool {
        guard let pitch = pitchName else { return false }
        let type = parsePitchType(pitch)

        switch type {
        case .agars, .dutchmans, .austins, .oeSoccer, .collegeField:
            return true
        default:
            return false
        }
    }

    /// Determine if a pitch belongs to South Fields
    static func isSouthFieldsPitch(_ pitchName: String?) -> Bool {
        guard let pitch = pitchName else { return false }
        let type = parsePitchType(pitch)

        switch type {
        case .southMeadow, .warres, .carters, .squareClose:
            return true
        default:
            return false
        }
    }

    // MARK: - Pitch Matching

    /// Check if two pitch names match by comparing their parsed types
    static func pitchNamesMatch(_ name1: String, _ name2: String) -> Bool {
        let type1 = parsePitchType(name1)
        let type2 = parsePitchType(name2)
        let matches = type1 == type2

        // Debug logging
        print("🎯 Comparing: '\(name1)' (\(type1)) vs '\(name2)' (\(type2)) = \(matches)")

        return matches
    }

    // MARK: - Private Helpers

    /// Parse a pitch name into its type and number (if applicable)
    private static func parsePitchType(_ name: String) -> PitchType {
        // Clean and lowercase the name
        let cleaned = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "'", with: "")  // Remove all apostrophes
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "`", with: "")
            .lowercased()

        // Extract numbers from the string
        let numbers = cleaned.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        let number = Int(numbers)

        // Match based on keywords (ignoring apostrophes and case)
        if cleaned.contains("agar") {
            return .agars(number ?? 0)
        }

        if cleaned.contains("dutchman") || cleaned.contains("dutchmna") {
            return .dutchmans(number ?? 0)
        }

        if cleaned.contains("austin") {
            return .austins
        }

        if cleaned.contains("o.e.") || cleaned.contains("oe") || cleaned.contains("soccer") {
            return .oeSoccer
        }

        if cleaned.contains("college") {
            return .collegeField
        }

        if cleaned.contains("south") && cleaned.contains("meadow") {
            return .southMeadow(number ?? 0)
        }

        if cleaned.contains("warre") {
            return .warres
        }

        if cleaned.contains("carter") {
            return .carters
        }

        if cleaned.contains("square") && cleaned.contains("close") {
            return .squareClose
        }

        // Handle abbreviated forms (A5, D12, S3, etc.)
        if cleaned.count <= 3 {  // Short enough to be an abbreviation
            if let firstChar = cleaned.first, let num = number {
                switch firstChar {
                case "a":
                    return .agars(num)
                case "d":
                    return .dutchmans(num)
                case "s":
                    return .southMeadow(num)
                default:
                    break
                }
            }
        }

        return .unknown(cleaned)
    }
}
