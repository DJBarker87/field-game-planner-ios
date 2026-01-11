//
//  Enums.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

// MARK: - Time Filter

/// Filter options for viewing matches by time period
enum TimeFilter: String, CaseIterable, Identifiable, Codable {
    case today = "Today"
    case tomorrow = "Tomorrow"
    case week = "This Week"
    case all = "All"

    var id: String { rawValue }

    /// Returns the date range for this filter
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        switch self {
        case .today:
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            return (startOfToday, endOfToday)

        case .tomorrow:
            let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            let endOfTomorrow = calendar.date(byAdding: .day, value: 2, to: startOfToday)!
            return (startOfTomorrow, endOfTomorrow)

        case .week:
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfToday)!
            return (startOfToday, endOfWeek)

        case .all:
            // Return a very wide range for "all"
            let farFuture = calendar.date(byAdding: .year, value: 1, to: now)!
            return (startOfToday, farFuture)
        }
    }

    /// Display icon for the filter
    var systemImage: String {
        switch self {
        case .today: return "sun.max"
        case .tomorrow: return "sun.horizon"
        case .week: return "calendar.badge.clock"
        case .all: return "calendar"
        }
    }
}

// MARK: - View Mode

/// Display mode for match lists
enum ViewMode: String, CaseIterable, Identifiable, Codable {
    case list = "List"
    case calendar = "Calendar"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .list: return "list.bullet"
        case .calendar: return "calendar"
        }
    }
}

// MARK: - Match Status

/// Status of a match
enum MatchStatus: String, Codable, CaseIterable, Identifiable {
    case scheduled = "scheduled"
    case completed = "completed"
    case cancelled = "cancelled"
    case postponed = "postponed"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .postponed: return "Postponed"
        }
    }

    var systemImage: String {
        switch self {
        case .scheduled: return "clock"
        case .completed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        case .postponed: return "pause.circle"
        }
    }
}

// MARK: - User Role

/// User roles for access control
enum UserRole: String, Codable, CaseIterable, Identifiable, Comparable {
    case viewer = "viewer"
    case captain = "captain"
    case admin = "admin"

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    /// Permission level (higher = more permissions)
    var permissionLevel: Int {
        switch self {
        case .viewer: return 0
        case .captain: return 1
        case .admin: return 2
        }
    }

    static func < (lhs: UserRole, rhs: UserRole) -> Bool {
        lhs.permissionLevel < rhs.permissionLevel
    }

    /// Check if this role can edit scores
    var canEditScores: Bool {
        self >= .captain
    }

    /// Check if this role has admin access
    var isAdmin: Bool {
        self == .admin
    }
}

// MARK: - Competition Type

/// Types of competitions
enum CompetitionType: String, Codable, CaseIterable, Identifiable {
    case seniorTies = "Senior Ties"
    case seniorLeague = "Senior League"
    case juniorLeague = "Junior League"
    case sixthFormLeague = "6th Form League"
    case lowerBoyLeague = "Lower Boy League"
    case knockoutCup = "Knockout Cup"
    case houseCup = "House Cup"
    case friendly = "Friendly"

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .seniorTies: return "ST"
        case .seniorLeague: return "SL"
        case .juniorLeague: return "JL"
        case .sixthFormLeague: return "6F"
        case .lowerBoyLeague: return "LB"
        case .knockoutCup: return "KC"
        case .houseCup: return "HC"
        case .friendly: return "FR"
        }
    }
}

// MARK: - Sort Order

/// Sort options for match lists
enum MatchSortOrder: String, CaseIterable, Identifiable {
    case dateAscending = "Date (Earliest)"
    case dateDescending = "Date (Latest)"
    case competition = "Competition"
    case team = "Team"

    var id: String { rawValue }
}

// MARK: - Field Location

/// Pitch location areas
enum FieldLocation: String, Codable, CaseIterable, Identifiable {
    case north = "North Fields"
    case south = "South Fields"
    case agar = "Agar's Plough"
    case dutchman = "Dutchman's"
    case other = "Other"

    var id: String { rawValue }
}
