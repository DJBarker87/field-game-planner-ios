//
//  Location.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import Foundation

/// Represents a pitch location
struct Location: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let pitchName: String?
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case pitchName = "pitch_name"
        case latitude
        case longitude
    }

    // MARK: - Equatable

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Preview

    static var preview: Location {
        Location(
            id: "1",
            name: "North Fields",
            pitchName: "Dutchman's 1",
            latitude: 51.4951,
            longitude: -0.6071
        )
    }

    static var previewList: [Location] {
        [
            Location(id: "1", name: "North Fields", pitchName: "Dutchman's 1", latitude: 51.4951, longitude: -0.6071),
            Location(id: "2", name: "North Fields", pitchName: "Dutchman's 2", latitude: 51.4952, longitude: -0.6072),
            Location(id: "3", name: "Agar's Plough", pitchName: "Pitch 1", latitude: 51.4948, longitude: -0.6065),
        ]
    }
}
