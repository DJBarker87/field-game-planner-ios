//
//  MonthlyCalendarView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import SwiftUI

/// A monthly calendar view showing matches
struct MonthlyCalendarView: View {
    let matches: [MatchWithHouses]
    let selectedTeamId: String?
    var onDateClick: ((Date) -> Void)?
    var onPitchClick: ((String) -> Void)?

    @State private var currentMonth: Date = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let paddingDays = firstWeekday - calendar.firstWeekday

        var days: [Date?] = Array(repeating: nil, count: (paddingDays + 7) % 7)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        // Pad to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func matchesForDate(_ date: Date) -> [MatchWithHouses] {
        let startOfDay = calendar.startOfDay(for: date)
        return matches.filter { calendar.startOfDay(for: $0.date) == startOfDay }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.etonPrimary)
                        .padding(8)
                }

                Spacer()

                Text(monthString)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.etonPrimary)
                        .padding(8)
                }
            }
            .padding(.horizontal)

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            matches: matchesForDate(date),
                            selectedTeamId: selectedTeamId,
                            isToday: calendar.isDateInToday(date),
                            onTap: {
                                onDateClick?(date)
                            },
                            onPitchClick: onPitchClick
                        )
                    } else {
                        Color.clear
                            .frame(height: 80)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

/// Individual day cell in the calendar
struct CalendarDayCell: View {
    let date: Date
    let matches: [MatchWithHouses]
    let selectedTeamId: String?
    let isToday: Bool
    var onTap: (() -> Void)?
    var onPitchClick: ((String) -> Void)?

    private let calendar = Calendar.current

    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    private var hasMatches: Bool {
        !matches.isEmpty
    }

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 2) {
                // Day number
                Text(dayNumber)
                    .font(.caption)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isToday ? .white : (hasMatches ? .primary : .secondary))
                    .frame(width: 24, height: 24)
                    .background(isToday ? Color.etonPrimary : Color.clear)
                    .cornerRadius(12)

                // Match indicators
                if hasMatches {
                    VStack(spacing: 1) {
                        ForEach(matches.prefix(3)) { match in
                            MatchIndicator(match: match, selectedTeamId: selectedTeamId)
                        }
                        if matches.count > 3 {
                            Text("+\(matches.count - 3)")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(hasMatches ? Color(.systemGray6).opacity(0.5) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

/// Small match indicator for calendar view
struct MatchIndicator: View {
    let match: MatchWithHouses
    let selectedTeamId: String?

    private var isInvolved: Bool {
        guard let teamId = selectedTeamId else { return true }
        return match.involves(teamIdString: teamId)
    }

    var body: some View {
        HStack(spacing: 2) {
            // Competition color indicator
            Circle()
                .fill(match.competitionColor)
                .frame(width: 4, height: 4)

            // Time
            if let time = match.time {
                Text(formatTime(time))
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(isInvolved ? match.competitionColor.opacity(0.15) : Color(.systemGray5))
        .cornerRadius(4)
    }

    private func formatTime(_ time: String) -> String {
        // Convert "HH:mm" to "H:mm" format
        let components = time.split(separator: ":")
        if let hour = components.first, let hourInt = Int(hour) {
            return "\(hourInt):\(components.last ?? "00")"
        }
        return time
    }
}

/// Expanded day view showing all matches for a selected date
struct DayMatchesView: View {
    let date: Date
    let matches: [MatchWithHouses]
    var onPitchClick: ((String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            Text(date.displayStringWithDay)
                .font(.headline)
                .padding(.horizontal)

            if matches.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("No fixtures on this day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(matches) { match in
                        CalendarMatchCard(match: match, onPitchClick: onPitchClick)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

/// Simplified match card for calendar view
struct CalendarMatchCard: View {
    let match: MatchWithHouses
    var onPitchClick: ((String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Time and competition
            HStack {
                if let time = match.time {
                    Text(time)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }

                Text(match.competitionType)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(match.competitionColor)
                    .cornerRadius(4)

                Spacer()
            }

            // Teams
            HStack {
                TeamView(name: match.homeTeamName, kitColors: match.homeKitColors)
                Spacer()
                Text("v")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                TeamView(name: match.awayTeamName ?? "", kitColors: match.awayKitColors)
            }

            // Pitch (tappable)
            if let pitch = match.pitch {
                Button {
                    onPitchClick?(pitch)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle")
                            .font(.caption)
                        Text(pitch)
                            .font(.caption)
                    }
                    .foregroundColor(.etonPrimary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview("Calendar") {
    MonthlyCalendarView(
        matches: [
            .preview,
            MatchWithHouses(
                id: "2",
                date: Date().addingTimeInterval(86400 * 2),
                time: "14:30",
                competitionType: "Junior League",
                pitch: "North Fields - Pitch 3",
                homeTeamId: "3",
                awayTeamId: "4",
                homeTeamName: "Godolphin",
                awayTeamName: "Villiers",
                homeTeamColours: "maroon/sky",
                awayTeamColours: "green/white",
                umpires: nil,
                status: "scheduled",
                homeScore: nil,
                awayScore: nil
            )
        ],
        selectedTeamId: nil
    )
}
