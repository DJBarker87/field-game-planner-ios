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
    let rect: CGRect  // Normalized coordinates (0-1)
}

// North Fields pitches
let NORTH_FIELDS_PITCHES: [String] = [
    "Dutchman's 1", "Dutchman's 2", "Dutchman's 3",
    "Agar's 1", "Agar's 2", "Agar's 3", "Agar's 4", "Agar's 5", "Agar's 6",
    "Sixpenny 1", "Sixpenny 2", "Sixpenny 3", "Sixpenny 4", "Sixpenny 5", "Sixpenny 6"
]

// South Fields pitches
let SOUTH_FIELDS_PITCHES: [String] = [
    "South Meadow 1", "South Meadow 2", "South Meadow 3", "South Meadow 4",
    "Field 1", "Field 2", "Field 3", "Field 4", "Field 5", "Field 6"
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

// MARK: - North Fields Map

struct NorthFieldsMap: View {
    let highlightedPitch: String?
    var onPitchClick: ((String) -> Void)?

    // Pitch layout data (normalized 0-1 coordinates)
    private let pitches: [PitchData] = [
        // Dutchman's (top row)
        PitchData(name: "Dutchman's 1", rect: CGRect(x: 0.05, y: 0.05, width: 0.28, height: 0.2)),
        PitchData(name: "Dutchman's 2", rect: CGRect(x: 0.36, y: 0.05, width: 0.28, height: 0.2)),
        PitchData(name: "Dutchman's 3", rect: CGRect(x: 0.67, y: 0.05, width: 0.28, height: 0.2)),

        // Agar's (middle rows)
        PitchData(name: "Agar's 1", rect: CGRect(x: 0.05, y: 0.3, width: 0.28, height: 0.2)),
        PitchData(name: "Agar's 2", rect: CGRect(x: 0.36, y: 0.3, width: 0.28, height: 0.2)),
        PitchData(name: "Agar's 3", rect: CGRect(x: 0.67, y: 0.3, width: 0.28, height: 0.2)),
        PitchData(name: "Agar's 4", rect: CGRect(x: 0.05, y: 0.52, width: 0.28, height: 0.2)),
        PitchData(name: "Agar's 5", rect: CGRect(x: 0.36, y: 0.52, width: 0.28, height: 0.2)),
        PitchData(name: "Agar's 6", rect: CGRect(x: 0.67, y: 0.52, width: 0.28, height: 0.2)),

        // Sixpenny (bottom rows)
        PitchData(name: "Sixpenny 1", rect: CGRect(x: 0.05, y: 0.75, width: 0.14, height: 0.2)),
        PitchData(name: "Sixpenny 2", rect: CGRect(x: 0.21, y: 0.75, width: 0.14, height: 0.2)),
        PitchData(name: "Sixpenny 3", rect: CGRect(x: 0.37, y: 0.75, width: 0.14, height: 0.2)),
        PitchData(name: "Sixpenny 4", rect: CGRect(x: 0.53, y: 0.75, width: 0.14, height: 0.2)),
        PitchData(name: "Sixpenny 5", rect: CGRect(x: 0.69, y: 0.75, width: 0.14, height: 0.2)),
        PitchData(name: "Sixpenny 6", rect: CGRect(x: 0.85, y: 0.75, width: 0.10, height: 0.2)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("North Fields")
                .font(.headline)
                .foregroundColor(.primary)

            GeometryReader { geometry in
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.2))

                    // Pitches
                    ForEach(pitches, id: \.name) { pitch in
                        PitchRectangle(
                            pitch: pitch,
                            isHighlighted: isPitchHighlighted(pitch.name),
                            geometry: geometry,
                            onTap: { onPitchClick?(pitch.name) }
                        )
                    }
                }
            }
            .aspectRatio(1.5, contentMode: .fit)
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

// MARK: - South Fields Map

struct SouthFieldsMap: View {
    let highlightedPitch: String?
    var onPitchClick: ((String) -> Void)?

    // Pitch layout data (normalized 0-1 coordinates)
    private let pitches: [PitchData] = [
        // South Meadow (top row)
        PitchData(name: "South Meadow 1", rect: CGRect(x: 0.05, y: 0.05, width: 0.22, height: 0.4)),
        PitchData(name: "South Meadow 2", rect: CGRect(x: 0.29, y: 0.05, width: 0.22, height: 0.4)),
        PitchData(name: "South Meadow 3", rect: CGRect(x: 0.53, y: 0.05, width: 0.22, height: 0.4)),
        PitchData(name: "South Meadow 4", rect: CGRect(x: 0.77, y: 0.05, width: 0.18, height: 0.4)),

        // Field (bottom rows)
        PitchData(name: "Field 1", rect: CGRect(x: 0.05, y: 0.5, width: 0.14, height: 0.45)),
        PitchData(name: "Field 2", rect: CGRect(x: 0.21, y: 0.5, width: 0.14, height: 0.45)),
        PitchData(name: "Field 3", rect: CGRect(x: 0.37, y: 0.5, width: 0.14, height: 0.45)),
        PitchData(name: "Field 4", rect: CGRect(x: 0.53, y: 0.5, width: 0.14, height: 0.45)),
        PitchData(name: "Field 5", rect: CGRect(x: 0.69, y: 0.5, width: 0.14, height: 0.45)),
        PitchData(name: "Field 6", rect: CGRect(x: 0.85, y: 0.5, width: 0.10, height: 0.45)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("South Fields")
                .font(.headline)
                .foregroundColor(.primary)

            GeometryReader { geometry in
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.2))

                    // Pitches
                    ForEach(pitches, id: \.name) { pitch in
                        PitchRectangle(
                            pitch: pitch,
                            isHighlighted: isPitchHighlighted(pitch.name),
                            geometry: geometry,
                            onTap: { onPitchClick?(pitch.name) }
                        )
                    }
                }
            }
            .aspectRatio(1.5, contentMode: .fit)
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

// MARK: - Pitch Rectangle

struct PitchRectangle: View {
    let pitch: PitchData
    let isHighlighted: Bool
    let geometry: GeometryProxy
    let onTap: () -> Void

    var body: some View {
        let rect = CGRect(
            x: pitch.rect.origin.x * geometry.size.width,
            y: pitch.rect.origin.y * geometry.size.height,
            width: pitch.rect.width * geometry.size.width,
            height: pitch.rect.height * geometry.size.height
        )

        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHighlighted ? Color.etonPrimary : Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(
                        isHighlighted ? Color.etonPrimary : Color.gray.opacity(0.3),
                        lineWidth: isHighlighted ? 2 : 1
                    )

                Text(pitch.name)
                    .font(.caption2)
                    .fontWeight(isHighlighted ? .bold : .regular)
                    .foregroundColor(isHighlighted ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(4)
            }
        }
        .buttonStyle(.plain)
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
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
        highlightedPitch == nil
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let pitch = highlightedPitch {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.etonPrimary)
                            Text(pitch)
                                .font(.subheadline)
                                .foregroundColor(.etonPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.etonPrimary.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if showBothMaps {
                        NorthFieldsMap(highlightedPitch: highlightedPitch)
                        SouthFieldsMap(highlightedPitch: highlightedPitch)
                    } else if showNorthMap {
                        NorthFieldsMap(highlightedPitch: highlightedPitch)
                    } else if showSouthMap {
                        SouthFieldsMap(highlightedPitch: highlightedPitch)
                    } else {
                        // Fallback: show both
                        NorthFieldsMap(highlightedPitch: highlightedPitch)
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
