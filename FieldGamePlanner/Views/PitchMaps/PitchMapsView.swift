//
//  PitchMapsView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct PitchMapsView: View {
    @State private var selectedMap: PitchMapType = .north

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Map", selection: $selectedMap) {
                    ForEach(PitchMapType.allCases) { mapType in
                        Text(mapType.rawValue).tag(mapType)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                switch selectedMap {
                case .north:
                    NorthFieldsMapView()
                case .south:
                    SouthFieldsMapView()
                }
            }
            .navigationTitle("Pitch Maps")
        }
    }
}

enum PitchMapType: String, CaseIterable, Identifiable {
    case north = "North Fields"
    case south = "South Fields"

    var id: String { rawValue }
}

#Preview {
    PitchMapsView()
}
