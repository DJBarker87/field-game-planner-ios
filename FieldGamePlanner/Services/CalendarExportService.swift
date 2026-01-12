//
//  CalendarExportService.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation
import EventKit

/// Service for exporting matches to device calendar and generating ICS files
actor CalendarExportService {
    static let shared = CalendarExportService()

    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Calendar Access

    /// Request access to the device calendar
    /// - Returns: True if access was granted
    func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }

    /// Check current authorization status
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    // MARK: - Export to Calendar

    /// Export matches to the device calendar
    /// - Parameter matches: Array of matches to export
    /// - Returns: Number of events successfully saved
    func exportMatches(_ matches: [MatchWithHouses]) async throws -> Int {
        // Ensure we have access
        guard try await requestAccess() else {
            throw CalendarExportError.accessDenied
        }

        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            throw CalendarExportError.noDefaultCalendar
        }

        var savedCount = 0

        for match in matches {
            let event = createEvent(for: match, in: calendar)

            do {
                try eventStore.save(event, span: .thisEvent)
                savedCount += 1
            } catch {
                // Continue with other matches if one fails
                print("Failed to save event for match \(match.id): \(error)")
            }
        }

        return savedCount
    }

    private func createEvent(for match: MatchWithHouses, in calendar: EKCalendar) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)

        // Title: "Home v Away" or team name
        event.title = "\(match.homeTeamName) v \(match.awayTeamName)"

        // Location
        event.location = match.fullLocationString

        // Start time
        let startDate = combineDateAndTime(date: match.matchDate, time: match.matchTime)
        event.startDate = startDate

        // Duration: 1 hour
        event.endDate = startDate.addingTimeInterval(3600)

        // Notes
        var notes = "Competition: \(match.competitionType)"
        if match.isCompleted, let score = match.scoreString {
            notes += "\nFinal Score: \(score)"
        }
        event.notes = notes

        event.calendar = calendar

        return event
    }

    private func combineDateAndTime(date: Date, time: String?) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)

        // Parse time string (format: "HH:mm" or "h:mm a")
        if let time = time {
            let timeFormatter = DateFormatter()

            // Try 24-hour format first
            timeFormatter.dateFormat = "HH:mm"
            if let parsedTime = timeFormatter.date(from: time) {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
            } else {
                // Try 12-hour format
                timeFormatter.dateFormat = "h:mm a"
                if let parsedTime = timeFormatter.date(from: time) {
                    let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
                    components.hour = timeComponents.hour
                    components.minute = timeComponents.minute
                }
            }
        }

        // Default time: 14:25 if no time provided
        if components.hour == nil {
            components.hour = 14
            components.minute = 25
        }

        return calendar.date(from: components) ?? date
    }

    // MARK: - ICS Generation

    /// Generate ICS data for matches (for sharing)
    /// - Parameter matches: Array of matches to include
    /// - Returns: ICS formatted data
    func generateICSData(_ matches: [MatchWithHouses]) -> Data {
        var icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Field Game Planner//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH

        """

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        dateFormatter.timeZone = TimeZone.current

        for match in matches {
            let startDate = combineDateAndTime(date: match.matchDate, time: match.matchTime)
            let endDate = startDate.addingTimeInterval(3600)

            let uid = match.id.uuidString
            let title = escapeICS("\(match.homeTeamName) v \(match.awayTeamName)")
            let location = escapeICS(match.fullLocationString ?? "")
            let description = escapeICS("Competition: \(match.competitionType)")

            icsContent += """
            BEGIN:VEVENT
            UID:\(uid)@fieldgameplanner
            DTSTAMP:\(dateFormatter.string(from: Date()))
            DTSTART:\(dateFormatter.string(from: startDate))
            DTEND:\(dateFormatter.string(from: endDate))
            SUMMARY:\(title)
            LOCATION:\(location)
            DESCRIPTION:\(description)
            END:VEVENT

            """
        }

        icsContent += "END:VCALENDAR"

        return icsContent.data(using: .utf8) ?? Data()
    }

    /// Escape special characters for ICS format
    private func escapeICS(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    // MARK: - Delete Events

    /// Remove previously exported events for matches
    /// - Parameter matchIds: IDs of matches whose events should be removed
    func removeEvents(for matchIds: [UUID]) async throws {
        guard try await requestAccess() else {
            throw CalendarExportError.accessDenied
        }

        let startDate = Date().addingTimeInterval(-365 * 24 * 3600) // 1 year ago
        let endDate = Date().addingTimeInterval(365 * 24 * 3600) // 1 year from now
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)

        let events = eventStore.events(matching: predicate)

        for matchId in matchIds {
            let searchTitle = matchId.uuidString
            if let event = events.first(where: { $0.notes?.contains(searchTitle) == true }) {
                try eventStore.remove(event, span: .thisEvent)
            }
        }
    }
}

// MARK: - Errors

enum CalendarExportError: LocalizedError {
    case accessDenied
    case noDefaultCalendar
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar access was denied. Please enable in Settings."
        case .noDefaultCalendar:
            return "No default calendar found."
        case .saveFailed(let error):
            return "Failed to save event: \(error.localizedDescription)"
        }
    }
}
