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
                        }
                        .position(x: width * 0.5, y: height * 0.25)

                        // Warre's (middle section)
                        VStack(spacing: 4) {
                            PitchBox(
                                name: "Warre's",
                                fullName: "Warre's",
                                isHighlighted: isPitchHighlighted("Warre's"),
                                width: 70
                            )
                        }
                        .position(x: width * 0.3, y: height * 0.5)

                        // Carter's (middle section)
                        VStack(spacing: 4) {
                            PitchBox(
                                name: "Carter's",
                                fullName: "Carter's",
                                isHighlighted: isPitchHighlighted("Carter's"),
                                width: 70
                            )
                        }
                        .position(x: width * 0.7, y: height * 0.5)

                        // Square Close (bottom section)
                        VStack(spacing: 4) {
                            PitchBox(
                                name: "Square Close",
                                fullName: "Square Close",
                                isHighlighted: isPitchHighlighted("Square Close"),
                                width: 85
                            )
                        }
                        .position(x: width * 0.5, y: height * 0.75)
                    }
                }
            }
        }
        .aspectRatio(1.2, contentMode: .fit)
    }

    private func isPitchHighlighted(_ pitchName: String) -> Bool {
        guard let highlighted = highlightedPitch else { return false }
        return PitchMapHelper.pitchNamesMatch(pitchName, highlighted)
    }
}

#Preview {
    SouthFieldsMapView(highlightedPitch: "South Meadow 3")
        .frame(height: 400)
        .padding()
}
