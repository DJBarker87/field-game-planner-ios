//
//  House.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct House: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let shortName: String?
    let kitColors: String

    var parsedKitColors: [Color] {
        KitColorMapper.parse(kitColors)
    }

    static var preview: House {
        House(
            id: UUID(),
            name: "Keate",
            shortName: "KT",
            kitColors: "red/white"
        )
    }
}
