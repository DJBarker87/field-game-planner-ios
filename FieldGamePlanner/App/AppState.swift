//
//  AppState.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI
import Combine

/// Global app state shared across the application
@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedHouse: String?

    @AppStorage("myHouse") var myHouse: String = ""

    init() {
        // Load saved preferences
        if !myHouse.isEmpty {
            selectedHouse = myHouse
        }
    }

    func setMyHouse(_ house: String) {
        myHouse = house
        selectedHouse = house
    }
}

/// Placeholder User model - will be expanded in Models
struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let role: String
}
