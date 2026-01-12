//
//  PitchMapSheet.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import SwiftUI

/// A sheet/drawer that shows pitch maps with an optional highlighted pitch
struct PitchMapSheet: View {
    @Environment(\.dismiss) private var dismiss

    let highlightedPitch: String?
    let title: String

    @State private var selectedMap: PitchMapType = .north

    init(highlightedPitch: String? = nil, title: String = "Playing Fields") {
        self.highlightedPitch = highlightedPitch
        self.title = title

        // Auto-select the map based on pitch name
        if let pitch = highlightedPitch?.lowercased() {
            if pitch.contains("south") || pitch.contains("sixpenny") {
                _selectedMap = State(initialValue: .south)
            } else {
                _selectedMap = State(initialValue: .north)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Map selector
                Picker("Map", selection: $selectedMap) {
                    ForEach(PitchMapType.allCases) { mapType in
                        Text(mapType.rawValue).tag(mapType)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Highlighted pitch info
                if let pitch = highlightedPitch {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.etonPrimary)
                        Text(pitch)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                // Map view
                ScrollView {
                    switch selectedMap {
                    case .north:
                        NorthFieldsMapView(highlightedPitch: highlightedPitch)
                            .padding()
                    case .south:
                        SouthFieldsMapView(highlightedPitch: highlightedPitch)
                            .padding()
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Compact pitch map for inline display
struct CompactPitchMap: View {
    let pitch: String?
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "map")
                    .font(.caption)
                Text(pitch ?? "View Map")
                    .font(.caption)
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(.caption2)
            }
            .foregroundColor(.etonPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.etonPrimary.opacity(0.1))
            .cornerRadius(6)
        }
    }
}

#Preview("Sheet") {
    PitchMapSheet(highlightedPitch: "Dutchman's 10", title: "Match Location")
}

#Preview("Sheet - No Highlight") {
    PitchMapSheet()
}

#Preview("Compact") {
    VStack {
        CompactPitchMap(pitch: "Dutchman's 5")
        CompactPitchMap(pitch: nil)
    }
    .padding()
}
