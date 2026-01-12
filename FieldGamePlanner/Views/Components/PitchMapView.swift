//
//  PitchMapView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import SwiftUI

// MARK: - Pitch Data

struct PitchData {
    let name: String
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let label: String

    init(name: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, label: String? = nil) {
        self.name = name
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.label = label ?? name
            .replacingOccurrences(of: "Dutchman's ", with: "D")
            .replacingOccurrences(of: "Agar's ", with: "A")
            .replacingOccurrences(of: "O.E. Soccer", with: "O.E.")
            .replacingOccurrences(of: "Austin's", with: "AUS")
            .replacingOccurrences(of: "College Field", with: "COLLEGE")
            .replacingOccurrences(of: "South Meadow ", with: "SM")
            .replacingOccurrences(of: "Sixpenny ", with: "6P")
            .replacingOccurrences(of: "Field ", with: "F")
    }
}

// North Fields pitches (Agar's & Dutchman's)
let NORTH_FIELDS_PITCHES: [String] = [
    "Agar's 1", "Agar's 2", "Agar's 3", "Agar's 4", "Agar's 5", "Agar's 6", "Agar's 7",
    "Austin's",
    "O.E. Soccer",
    "Dutchman's 1", "Dutchman's 2", "Dutchman's 3", "Dutchman's 4", "Dutchman's 5",
    "Dutchman's 6", "Dutchman's 7", "Dutchman's 8", "Dutchman's 9", "Dutchman's 10",
    "Dutchman's 11", "Dutchman's 12", "Dutchman's 13", "Dutchman's 14", "Dutchman's 15",
    "College Field"
]

// South Fields pitches (South Meadow & Surrounds)
let SOUTH_FIELDS_PITCHES: [String] = [
    "Warre's", "Carter's", "Square Close",
    "South Meadow 1", "South Meadow 2", "South Meadow 3", "South Meadow 4", "South Meadow 5"
]

// MARK: - Helper Functions

func normalizePitchName(_ name: String) -> String {
    name
        .replacingOccurrences(of: "'", with: "'")
        .replacingOccurrences(of: "`", with: "'")
        .replacingOccurrences(of: "Dutchmna's", with: "Dutchman's", options: .caseInsensitive)
        .trimmingCharacters(in: .whitespaces)
}

func isNorthFieldsPitch(_ pitchName: String) -> Bool {
    let normalized = normalizePitchName(pitchName).lowercased()
    return NORTH_FIELDS_PITCHES.contains { pitch in
        let normalizedPitch = normalizePitchName(pitch).lowercased()
        return normalizedPitch == normalized ||
               normalized.contains(normalizedPitch) ||
               normalizedPitch.contains(normalized)
    }
}

func isSouthFieldsPitch(_ pitchName: String) -> Bool {
    let normalized = normalizePitchName(pitchName).lowercased()
    return SOUTH_FIELDS_PITCHES.contains { pitch in
        let normalizedPitch = normalizePitchName(pitch).lowercased()
        return normalizedPitch == normalized ||
               normalized.contains(normalizedPitch) ||
               normalizedPitch.contains(normalized)
    }
}

// MARK: - North Fields Map (Agar's & Dutchman's)

struct NorthFieldsMap: View {
    let highlightedPitch: String?
    var onPitchClick: ((String) -> Void)?

    // SVG viewBox: 540 x 480
    private let viewBoxWidth: CGFloat = 540
    private let viewBoxHeight: CGFloat = 480

    private let pitches: [PitchData] = [
        // Agar's - Left side (vertical orientation)
        PitchData(name: "Agar's 5", x: 75, y: 90, width: 48, height: 58),
        PitchData(name: "Agar's 6", x: 128, y: 90, width: 48, height: 58),
        PitchData(name: "Agar's 3", x: 75, y: 153, width: 48, height: 58),
        PitchData(name: "Agar's 4", x: 128, y: 153, width: 48, height: 58),
        PitchData(name: "Agar's 1", x: 75, y: 216, width: 48, height: 58),
        PitchData(name: "Agar's 2", x: 128, y: 216, width: 48, height: 58),
        PitchData(name: "Agar's 7", x: 75, y: 289, width: 101, height: 58),

        // Austin's - left of Agar's
        PitchData(name: "Austin's", x: 38, y: 289, width: 32, height: 58),

        // Dutchman's - Main area
        PitchData(name: "O.E. Soccer", x: 205, y: 90, width: 101, height: 58),
        PitchData(name: "Dutchman's 7", x: 311, y: 90, width: 48, height: 58),
        PitchData(name: "Dutchman's 5", x: 205, y: 153, width: 48, height: 58),
        PitchData(name: "Dutchman's 6", x: 258, y: 153, width: 48, height: 58),
        PitchData(name: "Dutchman's 8", x: 311, y: 153, width: 48, height: 58),
        PitchData(name: "Dutchman's 3", x: 205, y: 216, width: 48, height: 58),
        PitchData(name: "Dutchman's 4", x: 258, y: 216, width: 48, height: 58),
        PitchData(name: "Dutchman's 1", x: 205, y: 289, width: 48, height: 58),
        PitchData(name: "Dutchman's 2", x: 258, y: 289, width: 48, height: 58),
        PitchData(name: "Dutchman's 15", x: 311, y: 289, width: 48, height: 58),

        // D9-D12 column
        PitchData(name: "Dutchman's 12", x: 385, y: 100, width: 52, height: 38),
        PitchData(name: "Dutchman's 11", x: 385, y: 143, width: 52, height: 38),
        PitchData(name: "Dutchman's 10", x: 385, y: 186, width: 52, height: 38),
        PitchData(name: "Dutchman's 9", x: 385, y: 229, width: 52, height: 38),

        // D13, D14
        PitchData(name: "Dutchman's 13", x: 462, y: 125, width: 52, height: 38),
        PitchData(name: "Dutchman's 14", x: 462, y: 168, width: 52, height: 38),

        // College Field
        PitchData(name: "College Field", x: 75, y: 410, width: 90, height: 45),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Agar's & Dutchman's")
                .font(.headline)
                .foregroundColor(.primary)

            GeometryReader { geometry in
                let scale = min(geometry.size.width / viewBoxWidth, geometry.size.height / viewBoxHeight)

                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.97, green: 0.98, blue: 0.97))

                    // Roads
                    Group {
                        // Slough Road - left edge
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8 * scale, height: 290 * scale)
                            .position(x: 30 * scale, y: 215 * scale)

                        // Avenue - between Agar's and Dutchman's
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 6 * scale, height: 290 * scale)
                            .position(x: 186 * scale, y: 215 * scale)

                        // Footpath - dashed
                        Path { path in
                            path.move(to: CGPoint(x: 447 * scale, y: 85 * scale))
                            path.addLine(to: CGPoint(x: 447 * scale, y: 290 * scale))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 4 * scale, dash: [4 * scale, 3 * scale]))
                        .foregroundColor(Color.gray.opacity(0.3))

                        // Pocock's Lane - horizontal
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 505 * scale, height: 6 * scale)
                            .position(x: 277 * scale, y: 380 * scale)
                    }

                    // Area Labels
                    Text("AGAR'S")
                        .font(.system(size: 11 * scale, weight: .semibold))
                        .foregroundColor(Color(white: 0.33))
                        .position(x: 113 * scale, y: 78 * scale)

                    Text("DUTCHMAN'S")
                        .font(.system(size: 11 * scale, weight: .semibold))
                        .foregroundColor(Color(white: 0.33))
                        .position(x: 285 * scale, y: 78 * scale)

                    // Road Labels
                    Text("SLOUGH ROAD")
                        .font(.system(size: 7 * scale, weight: .regular))
                        .foregroundColor(Color.gray)
                        .rotationEffect(.degrees(-90))
                        .position(x: 14 * scale, y: 220 * scale)

                    Text("AVENUE")
                        .font(.system(size: 7 * scale, weight: .regular))
                        .foregroundColor(Color.gray)
                        .rotationEffect(.degrees(-90))
                        .position(x: 192 * scale, y: 200 * scale)

                    Text("POCOCK'S LANE")
                        .font(.system(size: 8 * scale, weight: .regular))
                        .foregroundColor(Color.gray)
                        .position(x: 420 * scale, y: 390 * scale)

                    // Pavilion
                    RoundedRectangle(cornerRadius: 2 * scale)
                        .fill(Color(red: 0.83, green: 0.77, blue: 0.66))
                        .frame(width: 50 * scale, height: 22 * scale)
                        .overlay(
                            Text("PAV")
                                .font(.system(size: 8 * scale, weight: .medium))
                                .foregroundColor(Color(red: 0.4, green: 0.33, blue: 0.27))
                        )
                        .position(x: 125 * scale, y: 366 * scale)

                    // Pitches
                    ForEach(pitches, id: \.name) { pitch in
                        PitchRectangleView(
                            pitch: pitch,
                            isHighlighted: isPitchHighlighted(pitch.name),
                            scale: scale,
                            onTap: { onPitchClick?(pitch.name) }
                        )
                    }

                    // Compass
                    VStack(spacing: 2 * scale) {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 12 * scale))
                            .foregroundColor(Color.gray)
                        Text("N")
                            .font(.system(size: 9 * scale, weight: .medium))
                            .foregroundColor(Color.gray)
                    }
                    .position(x: 505 * scale, y: 50 * scale)
                }
            }
            .aspectRatio(viewBoxWidth / viewBoxHeight, contentMode: .fit)
        }
    }

    private func isPitchHighlighted(_ pitchName: String) -> Bool {
        guard let highlighted = highlightedPitch else { return false }
        let normalizedHighlighted = normalizePitchName(highlighted).lowercased()
        let normalizedPitch = normalizePitchName(pitchName).lowercased()
        return normalizedHighlighted.contains(normalizedPitch) ||
               normalizedPitch.contains(normalizedHighlighted)
    }
}

// MARK: - South Fields Map (South Meadow & Surrounds)

struct SouthFieldsMap: View {
    let highlightedPitch: String?
    var onPitchClick: ((String) -> Void)?

    // SVG viewBox: 450 x 470
    private let viewBoxWidth: CGFloat = 450
    private let viewBoxHeight: CGFloat = 470

    private let pitches: [PitchData] = [
        // Warre's and Carter's (left side)
        PitchData(name: "Warre's", x: 35, y: 105, width: 55, height: 50, label: "WARRE'S"),
        PitchData(name: "Carter's", x: 35, y: 165, width: 55, height: 50, label: "CARTER'S"),

        // Square Close (bottom left)
        PitchData(name: "Square Close", x: 85, y: 330, width: 60, height: 55, label: "SQUARE\nCLOSE"),

        // South Meadow pitches
        PitchData(name: "South Meadow 2", x: 295, y: 295, width: 55, height: 50),
        PitchData(name: "South Meadow 1", x: 355, y: 295, width: 55, height: 50),
        PitchData(name: "South Meadow 5", x: 185, y: 360, width: 45, height: 50),
        PitchData(name: "South Meadow 4", x: 235, y: 360, width: 45, height: 50),
        PitchData(name: "South Meadow 3", x: 295, y: 360, width: 55, height: 50),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("South Meadow & Surrounds")
                .font(.headline)
                .foregroundColor(.primary)

            GeometryReader { geometry in
                let scale = min(geometry.size.width / viewBoxWidth, geometry.size.height / viewBoxHeight)

                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.97, green: 0.98, blue: 0.97))

                    // Roads
                    Group {
                        // Eton Wick Road - top
                        Path { path in
                            path.move(to: CGPoint(x: 20 * scale, y: 90 * scale))
                            path.addLine(to: CGPoint(x: 430 * scale, y: 90 * scale))
                        }
                        .stroke(Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 8 * scale, lineCap: .round))

                        // S Meadow Lane - curved path
                        Path { path in
                            path.move(to: CGPoint(x: 420 * scale, y: 90 * scale))
                            path.addLine(to: CGPoint(x: 420 * scale, y: 250 * scale))
                            path.addLine(to: CGPoint(x: 280 * scale, y: 275 * scale))
                            path.addLine(to: CGPoint(x: 165 * scale, y: 275 * scale))
                            path.addLine(to: CGPoint(x: 165 * scale, y: 430 * scale))
                        }
                        .stroke(Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 8 * scale, lineCap: .round, lineJoin: .round))

                        // Meadow Lane - bottom
                        Path { path in
                            path.move(to: CGPoint(x: 20 * scale, y: 430 * scale))
                            path.addLine(to: CGPoint(x: 430 * scale, y: 430 * scale))
                        }
                        .stroke(Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 8 * scale, lineCap: .round))
                    }

                    // Road Labels
                    Text("ETON WICK ROAD")
                        .font(.system(size: 9 * scale, weight: .regular))
                        .foregroundColor(Color.gray)
                        .position(x: 130 * scale, y: 77 * scale)

                    Text("S MEADOW LANE")
                        .font(.system(size: 8 * scale, weight: .regular))
                        .foregroundColor(Color.gray)
                        .position(x: 300 * scale, y: 255 * scale)

                    Text("MEADOW LANE")
                        .font(.system(size: 9 * scale, weight: .regular))
                        .foregroundColor(Color.gray)
                        .position(x: 320 * scale, y: 450 * scale)

                    // Masters' Tennis Courts
                    RoundedRectangle(cornerRadius: 2 * scale)
                        .fill(Color(red: 0.94, green: 0.90, blue: 0.83))
                        .frame(width: 70 * scale, height: 110 * scale)
                        .overlay(
                            VStack(spacing: 2 * scale) {
                                Text("Masters'")
                                    .font(.system(size: 9 * scale, weight: .medium))
                                    .foregroundColor(Color(red: 0.54, green: 0.48, blue: 0.35))
                                Text("(tennis)")
                                    .font(.system(size: 7 * scale))
                                    .foregroundColor(Color(red: 0.66, green: 0.60, blue: 0.48))
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 2 * scale)
                                .stroke(Color(red: 0.79, green: 0.72, blue: 0.59), lineWidth: 1 * scale)
                        )
                        .position(x: 140 * scale, y: 160 * scale)

                    // Playground
                    RoundedRectangle(cornerRadius: 3 * scale)
                        .fill(Color(red: 0.91, green: 0.94, blue: 0.88))
                        .frame(width: 60 * scale, height: 50 * scale)
                        .overlay(
                            Text("Playground")
                                .font(.system(size: 8 * scale, weight: .medium))
                                .foregroundColor(Color(red: 0.42, green: 0.54, blue: 0.35))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 3 * scale)
                                .stroke(Color(red: 0.72, green: 0.83, blue: 0.66), lineWidth: 1 * scale)
                        )
                        .position(x: 130 * scale, y: 255 * scale)

                    // Treeline
                    Path { path in
                        path.move(to: CGPoint(x: 95 * scale, y: 230 * scale))
                        path.addLine(to: CGPoint(x: 95 * scale, y: 285 * scale))
                        path.addLine(to: CGPoint(x: 165 * scale, y: 285 * scale))
                    }
                    .stroke(Color(red: 0.29, green: 0.48, blue: 0.23).opacity(0.7), style: StrokeStyle(lineWidth: 5 * scale, lineCap: .round, lineJoin: .round))

                    // Tree symbols
                    ForEach([(95, 245), (95, 265), (115, 285), (140, 285)], id: \.0) { pos in
                        Circle()
                            .fill(Color(red: 0.35, green: 0.54, blue: 0.29))
                            .frame(width: 8 * scale, height: 8 * scale)
                            .position(x: CGFloat(pos.0) * scale, y: CGFloat(pos.1) * scale)
                    }

                    // Path indicator
                    Text("↓ to Square Close")
                        .font(.system(size: 7 * scale))
                        .foregroundColor(Color.gray)
                        .position(x: 130 * scale, y: 300 * scale)

                    // Pitches
                    ForEach(pitches, id: \.name) { pitch in
                        PitchRectangleView(
                            pitch: pitch,
                            isHighlighted: isPitchHighlighted(pitch.name),
                            scale: scale,
                            onTap: { onPitchClick?(pitch.name) }
                        )
                    }

                    // Compass
                    VStack(spacing: 2 * scale) {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 12 * scale))
                            .foregroundColor(Color.gray)
                        Text("N")
                            .font(.system(size: 9 * scale, weight: .medium))
                            .foregroundColor(Color.gray)
                    }
                    .position(x: 415 * scale, y: 50 * scale)
                }
            }
            .aspectRatio(viewBoxWidth / viewBoxHeight, contentMode: .fit)
        }
    }

    private func isPitchHighlighted(_ pitchName: String) -> Bool {
        guard let highlighted = highlightedPitch else { return false }
        let normalizedHighlighted = normalizePitchName(highlighted).lowercased()
        let normalizedPitch = normalizePitchName(pitchName).lowercased()
        return normalizedHighlighted.contains(normalizedPitch) ||
               normalizedPitch.contains(normalizedHighlighted)
    }
}

// MARK: - Pitch Rectangle View

struct PitchRectangleView: View {
    let pitch: PitchData
    let isHighlighted: Bool
    let scale: CGFloat
    let onTap: () -> Void

    private var fillColor: Color {
        if isHighlighted {
            return Color(red: 0.12, green: 0.30, blue: 0.55) // #1E4D8C
        }

        if pitch.name.contains("Agar") {
            return Color(red: 0.88, green: 0.93, blue: 0.88)
        } else if pitch.name.contains("Dutchman") || pitch.name == "O.E. Soccer" {
            return Color(red: 0.90, green: 0.94, blue: 0.90)
        } else if pitch.name == "College Field" {
            return Color(red: 0.85, green: 0.91, blue: 0.85)
        } else if pitch.name == "Austin's" {
            return Color(red: 0.91, green: 0.93, blue: 0.91)
        } else if pitch.name.contains("South Meadow") {
            return Color(red: 0.88, green: 0.93, blue: 0.88)
        } else if pitch.name.contains("Sixpenny") {
            return Color(red: 0.90, green: 0.94, blue: 0.90)
        } else if pitch.name.contains("Field") {
            return Color(red: 0.85, green: 0.91, blue: 0.85)
        }
        return Color(red: 0.91, green: 0.96, blue: 0.91)
    }

    private var strokeColor: Color {
        if isHighlighted {
            return Color(red: 0.08, green: 0.22, blue: 0.42) // #15396a
        }

        if pitch.name.contains("Agar") {
            return Color(red: 0.49, green: 0.65, blue: 0.49)
        } else if pitch.name.contains("Dutchman") || pitch.name == "O.E. Soccer" {
            return Color(red: 0.55, green: 0.69, blue: 0.55)
        } else if pitch.name == "College Field" {
            return Color(red: 0.42, green: 0.60, blue: 0.42)
        } else if pitch.name == "Austin's" {
            return Color(red: 0.54, green: 0.60, blue: 0.54)
        }
        return Color(red: 0.58, green: 0.66, blue: 0.58)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 2 * scale)
                    .fill(fillColor)
                    .frame(width: pitch.width * scale, height: pitch.height * scale)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2 * scale)
                            .stroke(strokeColor, lineWidth: isHighlighted ? 2.5 * scale : 1 * scale)
                    )
                    .shadow(color: isHighlighted ? Color(red: 0.12, green: 0.30, blue: 0.55).opacity(0.3) : .clear, radius: 4, x: 0, y: 2)

                Text(pitch.label)
                    .font(.system(size: fontSize * scale, weight: isHighlighted ? .semibold : .medium))
                    .foregroundColor(isHighlighted ? .white : Color(white: 0.27))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .position(x: (pitch.x + pitch.width / 2) * scale, y: (pitch.y + pitch.height / 2) * scale)
    }

    private var fontSize: CGFloat {
        if pitch.width < 45 { return 7 }
        if pitch.width < 55 { return 8 }
        return 9
    }
}

// MARK: - Pitch Map Sheet

struct PitchMapSheet: View {
    let highlightedPitch: String?
    @Environment(\.dismiss) private var dismiss

    private var showNorthMap: Bool {
        guard let pitch = highlightedPitch else { return true }
        return isNorthFieldsPitch(pitch)
    }

    private var showSouthMap: Bool {
        guard let pitch = highlightedPitch else { return true }
        return isSouthFieldsPitch(pitch)
    }

    private var showBothMaps: Bool {
        highlightedPitch == nil || (!showNorthMap && !showSouthMap)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let pitch = highlightedPitch {
                        HStack {
                            Circle()
                                .fill(Color.etonPrimary)
                                .frame(width: 8, height: 8)
                            Text(pitch)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.etonPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.etonPrimary.opacity(0.1))
                        .cornerRadius(20)
                    }

                    if showBothMaps {
                        NorthFieldsMap(highlightedPitch: highlightedPitch)
                        SouthFieldsMap(highlightedPitch: highlightedPitch)
                    } else if showNorthMap {
                        NorthFieldsMap(highlightedPitch: highlightedPitch)
                    } else if showSouthMap {
                        SouthFieldsMap(highlightedPitch: highlightedPitch)
                    }
                }
                .padding()
            }
            .navigationTitle("Playing Fields")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PitchMapSheet(highlightedPitch: "Agar's 3")
}
