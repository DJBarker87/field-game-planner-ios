//
//  Constants.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

enum Constants {
    enum App {
        static let name = "Field Game Planner"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.etonfieldgame.planner"
    }

    enum API {
        static let defaultPageSize = 20
        static let maxPageSize = 100
        static let cacheExpiration: TimeInterval = 5 * 60 // 5 minutes
    }

    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.8
    }

    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
    }

    enum DateFormat {
        static let display = "d MMM yyyy"
        static let displayWithDay = "EEEE, d MMM"
        static let api = "yyyy-MM-dd"
        static let time = "HH:mm"
        static let displayTime = "h:mm a"
    }
}
