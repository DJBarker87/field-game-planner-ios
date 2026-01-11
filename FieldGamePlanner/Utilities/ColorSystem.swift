//
//  ColorSystem.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

extension Color {
    // Primary brand color
    static let etonGreen = Color(hex: "#96c8a2")

    // Competition colors
    static let seniorLeague = Color.navy
    static let juniorLeague = Color.teal
    static let sixthFormLeague = Color.purple
    static let knockoutCup = Color.gold

    // Additional colors
    static let navy = Color(hex: "#1e3a5f")
    static let teal = Color(hex: "#2a9d8f")
    static let gold = Color(hex: "#d4a574")

    /// Returns the appropriate color for a competition type
    static func competitionColor(for competition: String) -> Color {
        let lowercased = competition.lowercased()

        if lowercased.contains("senior") {
            return .seniorLeague
        } else if lowercased.contains("junior") {
            return .juniorLeague
        } else if lowercased.contains("sixth") || lowercased.contains("6th") {
            return .sixthFormLeague
        } else if lowercased.contains("cup") || lowercased.contains("knockout") {
            return .knockoutCup
        }

        return .etonGreen
    }

    /// Initialize a Color from a hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// Maps kit color strings like "red/white" to SwiftUI Colors
enum KitColorMapper {
    private static let colorMap: [String: Color] = [
        "red": .red,
        "blue": .blue,
        "green": .green,
        "yellow": .yellow,
        "orange": .orange,
        "purple": .purple,
        "pink": .pink,
        "white": .white,
        "black": .black,
        "gray": .gray,
        "grey": .gray,
        "brown": .brown,
        "navy": Color(hex: "#1e3a5f"),
        "maroon": Color(hex: "#800000"),
        "gold": Color(hex: "#ffd700"),
        "silver": Color(hex: "#c0c0c0"),
        "teal": Color(hex: "#008080"),
        "cyan": .cyan,
        "lime": Color(hex: "#32cd32"),
        "crimson": Color(hex: "#dc143c"),
        "scarlet": Color(hex: "#ff2400"),
        "claret": Color(hex: "#7f1734"),
        "sky": Color(hex: "#87ceeb"),
        "royal": Color(hex: "#4169e1"),
    ]

    /// Parse a kit color string like "red/white" into an array of Colors
    static func parse(_ colorString: String) -> [Color] {
        guard !colorString.isEmpty else {
            return [.gray]
        }

        let colorNames = colorString
            .lowercased()
            .split(separator: "/")
            .map { String($0).trimmingCharacters(in: .whitespaces) }

        let colors = colorNames.compactMap { colorMap[$0] }

        return colors.isEmpty ? [.gray] : colors
    }
}
