//
//  ColorSystem.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

// MARK: - Color Extension

extension Color {
    // MARK: - Eton Palette

    /// Primary Eton Green
    static let etonPrimary = Color(hex: "#96c8a2")

    /// Eton color scale
    static let eton50 = Color(hex: "#f4f9f5")
    static let eton100 = Color(hex: "#e6f2e9")
    static let eton200 = Color(hex: "#cce5d3")
    static let eton300 = Color(hex: "#a8d4b5")
    static let eton400 = Color(hex: "#96c8a2")
    static let eton500 = Color(hex: "#6aad7a")
    static let eton600 = Color(hex: "#528c61")
    static let eton700 = Color(hex: "#43714f")
    static let eton800 = Color(hex: "#385c42")
    static let eton900 = Color(hex: "#2f4c37")

    /// Legacy alias for etonPrimary
    static let etonGreen = etonPrimary

    // MARK: - Competition Colors

    /// Senior Ties - Gold
    static let seniorTies = Color(hex: "#d4a574")

    /// Senior League - Navy
    static let seniorLeague = Color(hex: "#1e3a5f")

    /// Junior League - Teal
    static let juniorLeague = Color(hex: "#2a9d8f")

    /// 6th Form League - Purple
    static let sixthFormLeague = Color(hex: "#7c3aed")

    /// Lower Boy League - Coral
    static let lowerBoyLeague = Color(hex: "#f97316")

    /// Knockout Cup - Crimson
    static let knockoutCup = Color(hex: "#dc2626")

    /// House Cup - Emerald
    static let houseCup = Color(hex: "#10b981")

    /// Friendly - Gray
    static let friendly = Color(hex: "#6b7280")

    // MARK: - Additional Named Colors

    static let navy = Color(hex: "#1e3a5f")
    static let teal = Color(hex: "#2a9d8f")
    static let gold = Color(hex: "#d4a574")
    static let coral = Color(hex: "#f97316")
    static let emerald = Color(hex: "#10b981")
    static let crimson = Color(hex: "#dc2626")

    // MARK: - Competition Color Mapping

    /// Returns the appropriate color for a competition type
    /// - Parameter competition: The competition name string
    /// - Returns: The color associated with that competition
    static func competitionColor(for competition: String) -> Color {
        let lowercased = competition.lowercased()

        // Senior Ties (Gold)
        if lowercased.contains("senior") && lowercased.contains("ties") {
            return .seniorTies
        }

        // Senior League (Navy)
        if lowercased.contains("senior") && lowercased.contains("league") {
            return .seniorLeague
        }

        // Junior League (Teal)
        if lowercased.contains("junior") && lowercased.contains("league") {
            return .juniorLeague
        }

        // 6th Form League (Purple)
        if lowercased.contains("6th") || lowercased.contains("sixth") {
            return .sixthFormLeague
        }

        // Lower Boy League (Coral/Orange)
        if lowercased.contains("lower") && lowercased.contains("boy") {
            return .lowerBoyLeague
        }

        // House Cup (Emerald) - check before generic cup
        if lowercased.contains("house") && lowercased.contains("cup") {
            return .houseCup
        }

        // Knockout Cup (Crimson)
        if lowercased.contains("knockout") || lowercased.contains("cup") {
            return .knockoutCup
        }

        // Friendly (Gray)
        if lowercased.contains("friendly") {
            return .friendly
        }

        // Default to Eton Primary
        return .etonPrimary
    }

    // MARK: - Hex Initializer

    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex color string (e.g., "#FF0000", "FF0000", "#F00")
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
            (a, r, g, b) = (255, 128, 128, 128) // Default gray
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Convert Color to hex string
    var hexString: String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Kit Color Mapper

/// Maps kit color strings like "red/white" to SwiftUI Colors
struct KitColorMapper {

    /// Comprehensive color map with 30+ colors
    static let colorMap: [String: Color] = [
        // Basic colors
        "red": Color(hex: "#ef4444"),
        "blue": Color(hex: "#3b82f6"),
        "green": Color(hex: "#22c55e"),
        "yellow": Color(hex: "#eab308"),
        "orange": Color(hex: "#f97316"),
        "purple": Color(hex: "#a855f7"),
        "pink": Color(hex: "#ec4899"),
        "white": Color(hex: "#ffffff"),
        "black": Color(hex: "#000000"),
        "gray": Color(hex: "#6b7280"),
        "grey": Color(hex: "#6b7280"),
        "brown": Color(hex: "#92400e"),

        // Blues
        "navy": Color(hex: "#1e3a5f"),
        "royal": Color(hex: "#4169e1"),
        "sky": Color(hex: "#87ceeb"),
        "light blue": Color(hex: "#87ceeb"),
        "lightblue": Color(hex: "#87ceeb"),
        "dark blue": Color(hex: "#1e3a5f"),
        "darkblue": Color(hex: "#1e3a5f"),
        "cambridge": Color(hex: "#a3c1ad"),
        "oxford": Color(hex: "#002147"),
        "cobalt": Color(hex: "#0047ab"),
        "azure": Color(hex: "#007fff"),
        "cyan": Color(hex: "#00bcd4"),
        "teal": Color(hex: "#008080"),
        "turquoise": Color(hex: "#40e0d0"),

        // Reds
        "maroon": Color(hex: "#800000"),
        "crimson": Color(hex: "#dc143c"),
        "scarlet": Color(hex: "#ff2400"),
        "claret": Color(hex: "#7f1734"),
        "burgundy": Color(hex: "#800020"),
        "cherry": Color(hex: "#de3163"),
        "cardinal": Color(hex: "#c41e3a"),
        "ruby": Color(hex: "#e0115f"),
        "wine": Color(hex: "#722f37"),
        "rose": Color(hex: "#ff007f"),
        "coral": Color(hex: "#ff7f50"),
        "salmon": Color(hex: "#fa8072"),

        // Greens
        "emerald": Color(hex: "#50c878"),
        "forest": Color(hex: "#228b22"),
        "lime": Color(hex: "#32cd32"),
        "olive": Color(hex: "#808000"),
        "mint": Color(hex: "#98fb98"),
        "sage": Color(hex: "#b2ac88"),
        "hunter": Color(hex: "#355e3b"),
        "jade": Color(hex: "#00a86b"),
        "eton": Color(hex: "#96c8a2"),

        // Yellows/Golds
        "gold": Color(hex: "#ffd700"),
        "amber": Color(hex: "#ffbf00"),
        "mustard": Color(hex: "#ffdb58"),
        "cream": Color(hex: "#fffdd0"),
        "lemon": Color(hex: "#fff44f"),
        "honey": Color(hex: "#eb9605"),
        "sand": Color(hex: "#c2b280"),
        "buff": Color(hex: "#f0dc82"),

        // Purples
        "violet": Color(hex: "#8b00ff"),
        "lavender": Color(hex: "#e6e6fa"),
        "mauve": Color(hex: "#e0b0ff"),
        "plum": Color(hex: "#dda0dd"),
        "indigo": Color(hex: "#4b0082"),
        "magenta": Color(hex: "#ff00ff"),
        "lilac": Color(hex: "#c8a2c8"),

        // Neutrals
        "silver": Color(hex: "#c0c0c0"),
        "charcoal": Color(hex: "#36454f"),
        "slate": Color(hex: "#708090"),
        "ash": Color(hex: "#b2beb5"),
        "ivory": Color(hex: "#fffff0"),
        "beige": Color(hex: "#f5f5dc"),
        "tan": Color(hex: "#d2b48c"),
        "khaki": Color(hex: "#c3b091"),

        // Other
        "copper": Color(hex: "#b87333"),
        "bronze": Color(hex: "#cd7f32"),
        "rust": Color(hex: "#b7410e"),
        "peach": Color(hex: "#ffcba4"),
        "apricot": Color(hex: "#fbceb1"),
    ]

    /// Parse a kit color string like "red/white" into an array of Colors
    /// - Parameter colorString: The color string (e.g., "red/white", "navy/gold/white")
    /// - Returns: An array of parsed Colors
    static func parse(_ colorString: String) -> [Color] {
        guard !colorString.isEmpty else {
            return [Color(hex: "#6b7280")] // Default gray
        }

        let colorNames = colorString
            .lowercased()
            .split(separator: "/")
            .map { String($0).trimmingCharacters(in: .whitespaces) }

        let colors = colorNames.compactMap { colorMap[$0] }

        return colors.isEmpty ? [Color(hex: "#6b7280")] : colors
    }

    /// Check if a color string is valid (all colors can be parsed)
    /// - Parameter colorString: The color string to validate
    /// - Returns: True if all colors in the string are recognized
    static func isValid(_ colorString: String) -> Bool {
        guard !colorString.isEmpty else { return false }

        let colorNames = colorString
            .lowercased()
            .split(separator: "/")
            .map { String($0).trimmingCharacters(in: .whitespaces) }

        return colorNames.allSatisfy { colorMap[$0] != nil }
    }

    /// Get all available color names
    static var availableColors: [String] {
        colorMap.keys.sorted()
    }
}

// MARK: - SwiftUI Preview

#Preview("Color System") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            // Eton Palette
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Eton Palette")
                        .font(.headline)

                    HStack(spacing: 4) {
                        ColorSwatch(color: .eton50, label: "50")
                        ColorSwatch(color: .eton100, label: "100")
                        ColorSwatch(color: .eton200, label: "200")
                        ColorSwatch(color: .eton300, label: "300")
                        ColorSwatch(color: .eton400, label: "400")
                    }
                    HStack(spacing: 4) {
                        ColorSwatch(color: .eton500, label: "500")
                        ColorSwatch(color: .eton600, label: "600")
                        ColorSwatch(color: .eton700, label: "700")
                        ColorSwatch(color: .eton800, label: "800")
                        ColorSwatch(color: .eton900, label: "900")
                    }
                }
            }

            Divider()

            // Competition Colors
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Competition Colors")
                        .font(.headline)

                    CompetitionColorRow(name: "Senior Ties", color: .competitionColor(for: "Senior Ties"))
                    CompetitionColorRow(name: "Senior League", color: .competitionColor(for: "Senior League"))
                    CompetitionColorRow(name: "Junior League", color: .competitionColor(for: "Junior League"))
                    CompetitionColorRow(name: "6th Form League", color: .competitionColor(for: "6th Form League"))
                    CompetitionColorRow(name: "Lower Boy League", color: .competitionColor(for: "Lower Boy League"))
                    CompetitionColorRow(name: "Knockout Cup", color: .competitionColor(for: "Knockout Cup"))
                    CompetitionColorRow(name: "Friendly", color: .competitionColor(for: "Friendly"))
                }
            }

            Divider()

            // Kit Color Parsing
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kit Color Parsing")
                        .font(.headline)

                    KitColorPreview(colorString: "red/white")
                    KitColorPreview(colorString: "navy/gold")
                    KitColorPreview(colorString: "maroon/sky/white")
                    KitColorPreview(colorString: "eton/white")
                    KitColorPreview(colorString: "claret/cambridge")
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview Helpers

private struct ColorSwatch: View {
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

private struct CompetitionColorRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 24, height: 24)
            Text(name)
                .font(.subheadline)
            Spacer()
        }
    }
}

private struct KitColorPreview: View {
    let colorString: String

    var body: some View {
        HStack {
            HStack(spacing: 0) {
                ForEach(Array(KitColorMapper.parse(colorString).enumerated()), id: \.offset) { _, color in
                    Rectangle()
                        .fill(color)
                        .frame(width: 20, height: 30)
                }
            }
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            Text(colorString)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
