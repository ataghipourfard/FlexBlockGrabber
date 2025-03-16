//
//  DateFormatter+Extensions.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation

extension DateFormatter {
    // For API communication (ISO8601)
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    // For display (US format)
    static let usDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    // For display with time (US format)
    static let usDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy h:mm a"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    // For day display
    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full day name
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    // For month display
    static let monthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // e.g., "Jan 15"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    // For time only
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // e.g., "3:30 PM"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}

extension JSONDecoder {
    static let iso8601: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
}

extension JSONEncoder {
    static let iso8601: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        return encoder
    }()
}

// Date extension for formatted strings
extension Date {
    var usDateString: String {
        return DateFormatter.usDateOnly.string(from: self)
    }
    
    var usDateTimeString: String {
        return DateFormatter.usDateTime.string(from: self)
    }
    
    var dayOfWeekString: String {
        return DateFormatter.dayOfWeek.string(from: self)
    }
    
    var monthDayString: String {
        return DateFormatter.monthDay.string(from: self)
    }
    
    var timeString: String {
        return DateFormatter.timeOnly.string(from: self)
    }
}
