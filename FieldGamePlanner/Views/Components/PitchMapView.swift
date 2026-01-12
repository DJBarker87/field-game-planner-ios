//
//  PitchMapView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import SwiftUI

/// A view that displays the appropriate pitch map based on location
struct PitchMapView: View {
    let location: String?
    let highlightedPitch: String?

    init(location: String? = nil, highlightedPitch: String? = nil) {
        self.location = location
        self.highlightedPitch = highlightedPitch
    }

    private var mapType: PitchMapType {
        guard let location = location?.lowercased() else { return .north }

        if location.contains("south") || location.contains("sixpenny") ||
           location.contains("rafts") || location.contains("club") {
            return .south
        }
        return .north
    }

    var body: some View {
        Group {
            switch mapType {
            case .north:
                NorthFieldsMapView(highlightedPitch: highlightedPitch ?? location)
            case .south:
                SouthFieldsMapView(highlightedPitch: highlightedPitch ?? location)
            }
        }
    }
}

#Preview {
    VStack {
        PitchMapView(location: "Dutchman's 5", highlightedPitch: "Dutchman's 5")
            .frame(height: 300)

        PitchMapView(location: "Sixpenny 3", highlightedPitch: "Sixpenny 3")
            .frame(height: 300)
    }
    .padding()
}
