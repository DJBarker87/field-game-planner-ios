//
//  NorthFieldsMapView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct NorthFieldsMapView: View {
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
                    Text("North Fields")
                        .font(.headline)
                        .padding(.top, 8)

                    // Main map area
                    ZStack {
                        // Agar's Plough (top section)
                        VStack(spacing: 2) {
                            Text("Agar's Plough")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 2) {
                                ForEach(1...7, id: \.self) { num in
                                    PitchBox(
                                        name: "A\(num)",
                                        fullName: "Agar's \(num)",
                                        isHighlighted: isPitchHighlighted("Agar's \(num)")
                                    )
                                }
                            }
                        }
                        .position(x: width * 0.5, y: height * 0.12)

                        // Dutchman's (main section)
                        VStack(spacing: 4) {
                            Text("Dutchman's")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            // Row 1: D1-D4
                            HStack(spacing: 2) {
                                ForEach(1...4, id: \.self) { num in
                                    PitchBox(
                                        name: "D\(num)",
                                        fullName: "Dutchman's \(num)",
                                        isHighlighted: isPitchHighlighted("Dutchman's \(num)")
                                    )
                                }
                            }

                            // Row 2: D5-D8
                            HStack(spacing: 2) {
                                ForEach(5...8, id: \.self) { num in
                                    PitchBox(
                                        name: "D\(num)",
                                        fullName: "Dutchman's \(num)",
                                        isHighlighted: isPitchHighlighted("Dutchman's \(num)")
                                    )
                                }
                            }

                            // Row 3: D9-D12, then Avenue, then D13-D14
                            HStack(spacing: 2) {
                                // D9-D12
                                ForEach(9...12, id: \.self) { num in
                                    PitchBox(
                                        name: "D\(num)",
                                        fullName: "Dutchman's \(num)",
                                        isHighlighted: isPitchHighlighted("Dutchman's \(num)")
                                    )
                                }

                                // The Avenue
                                VStack {
                                    Text("The")
                                        .font(.system(size: 8))
                                    Text("Avenue")
                                        .font(.system(size: 8))
                                }
                                .frame(width: 35, height: 35)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(4)

                                // D13-D14
                                ForEach(13...14, id: \.self) { num in
                                    PitchBox(
                                        name: "D\(num)",
                                        fullName: "Dutchman's \(num)",
                                        isHighlighted: isPitchHighlighted("Dutchman's \(num)")
                                    )
                                }
                            }

                            // D15
                            HStack {
                                PitchBox(
                                    name: "D15",
                                    fullName: "Dutchman's 15",
                                    isHighlighted: isPitchHighlighted("Dutchman's 15")
                                )
                            }
                        }
                        .position(x: width * 0.5, y: height * 0.45)

                        // Bottom row: Austin's, OE Soccer, College Field
                        HStack(spacing: 12) {
                            PitchBox(
                                name: "Austin's",
                                fullName: "Austin's",
                                isHighlighted: isPitchHighlighted("Austin's"),
                                width: 60
                            )

                            PitchBox(
                                name: "O.E. Soccer",
                                fullName: "O.E. Soccer",
                                isHighlighted: isPitchHighlighted("O.E. Soccer"),
                                width: 70
                            )

                            PitchBox(
                                name: "College Field",
                                fullName: "College Field",
                                isHighlighted: isPitchHighlighted("College Field"),
                                width: 80
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
        guard let highlighted = highlightedPitch else {
            print("⚠️ No highlighted pitch set")
            return false
        }
        print("🔍 Checking if '\(pitchName)' should be highlighted (target: '\(highlighted)')")
        return PitchMapHelper.pitchNamesMatch(pitchName, highlighted)
    }
}

struct PitchBox: View {
    let name: String
    let fullName: String
    let isHighlighted: Bool
    var width: CGFloat = 35

    var body: some View {
        Text(name)
            .font(.system(size: 9, weight: isHighlighted ? .bold : .regular))
            .frame(width: width, height: 35)
            .background(isHighlighted ? Color.green.opacity(0.6) : Color.green.opacity(0.2))
            .foregroundStyle(isHighlighted ? .white : .primary)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isHighlighted ? Color.green : Color.green.opacity(0.5), lineWidth: isHighlighted ? 2 : 1)
            )
    }
}

#Preview {
    NorthFieldsMapView(highlightedPitch: "Dutchman's 10")
        .frame(height: 400)
        .padding()
}
