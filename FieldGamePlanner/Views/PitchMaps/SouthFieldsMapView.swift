//
//  SouthFieldsMapView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct SouthFieldsMapView: View {
    let highlightedPitch: String?

    init(highlightedPitch: String? = nil) {
        self.highlightedPitch = highlightedPitch
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                // Background
                Color(.systemBackground)

                VStack(spacing: 4) {
                    // Title
                    Text("South Fields")
                        .font(.headline)
                        .padding(.top, 8)

                    // Main map area
                    ZStack {
                        // South Meadow (main section)
                        VStack(spacing: 4) {
                            Text("South Meadow")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            // Row 1: S1-S5
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { num in
                                    PitchBox(
                                        name: "S\(num)",
                                        fullName: "South Meadow \(num)",
                                        isHighlighted: isPitchHighlighted("South Meadow \(num)")
                                    )
                                }
                            }

                            // Row 2: S6-S10
                            HStack(spacing: 2) {
                                ForEach(6...10, id: \.self) { num in
                                    PitchBox(
                                        name: "S\(num)",
                                        fullName: "South Meadow \(num)",
                                        isHighlighted: isPitchHighlighted("South Meadow \(num)")
                                    )
                                }
                            }
                        }
                        .position(x: width * 0.5, y: height * 0.25)

                        // Sixpenny (bottom section)
                        VStack(spacing: 4) {
                            Text("Sixpenny")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 2) {
                                ForEach(1...6, id: \.self) { num in
                                    PitchBox(
                                        name: "6P\(num)",
                                        fullName: "Sixpenny \(num)",
                                        isHighlighted: isPitchHighlighted("Sixpenny \(num)")
                                    )
                                }
                            }
                        }
                        .position(x: width * 0.5, y: height * 0.55)

                        // Special pitches at bottom
                        HStack(spacing: 12) {
                            PitchBox(
                                name: "Rafts",
                                fullName: "Rafts",
                                isHighlighted: isPitchHighlighted("Rafts"),
                                width: 50
                            )

                            PitchBox(
                                name: "Upper Club",
                                fullName: "Upper Club",
                                isHighlighted: isPitchHighlighted("Upper Club"),
                                width: 70
                            )

                            PitchBox(
                                name: "Lower Club",
                                fullName: "Lower Club",
                                isHighlighted: isPitchHighlighted("Lower Club"),
                                width: 70
                            )
                        }
                        .position(x: width * 0.5, y: height * 0.85)
                    }
                }
            }
        }
        .aspectRatio(1.2, contentMode: .fit)
    }

    private func isPitchHighlighted(_ pitchName: String) -> Bool {
        guard let highlighted = highlightedPitch else { return false }
        return pitchName.lowercased().contains(highlighted.lowercased()) ||
               highlighted.lowercased().contains(pitchName.lowercased())
    }
}

#Preview {
    SouthFieldsMapView(highlightedPitch: "Sixpenny 3")
        .frame(height: 400)
        .padding()
}
