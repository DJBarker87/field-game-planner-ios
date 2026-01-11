//
//  DateFormatters.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

extension DateFormatter {
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.display
        return formatter
    }()

    static let displayDateWithDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.displayWithDay
        return formatter
    }()

    static let apiDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.api
        return formatter
    }()

    static let displayTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.displayTime
        return formatter
    }()
}

extension Date {
    var displayString: String {
        DateFormatter.displayDate.string(from: self)
    }

    var displayStringWithDay: String {
        DateFormatter.displayDateWithDay.string(from: self)
    }

    var apiString: String {
        DateFormatter.apiDate.string(from: self)
    }

    var timeString: String {
        DateFormatter.displayTime.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var relativeDescription: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else if isThisWeek {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        } else {
            return displayStringWithDay
        }
    }
}
