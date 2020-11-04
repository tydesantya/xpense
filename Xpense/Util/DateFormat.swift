//
//  DateFormat.swift
//  Xpense
//
//  Created by Teddy Santya on 25/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func todayShortFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent // Using system locale
        dateFormatter.doesRelativeDateFormatting = true // Enabling relative date formatting
        
        // other dataFormatter settings here, irrelevant for example
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    func dateTimeFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent // Using system locale
        dateFormatter.doesRelativeDateFormatting = true // Enabling relative date formatting
        
        // other dataFormatter settings here, irrelevant for example
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: self)
    }
    
    func dayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent // Using system locale
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    func byAdding(component: Calendar.Component, value: Int, wrappingComponents: Bool = false, using calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: component, value: value, to: self, wrappingComponents: wrappingComponents)
    }
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .iso8601) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    func startOfWeek(using calendar: Calendar = .iso8601) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    func startOfMonth(using calendar: Calendar = .iso8601) -> Date {
        calendar.date(from: dateComponents([.year, .month], using: calendar))!
    }
    func startOfYear(using calendar: Calendar = .iso8601) -> Date {
        calendar.date(from: dateComponents([.year], using: calendar))!
    }
    var noon: Date {
        Calendar.iso8601.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var startOfDay: Date {
        return Calendar.iso8601.startOfDay(for: self)
    }
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.iso8601.date(byAdding: components, to: startOfDay)!
    }
    var endOfWeek: Date {
        var components = DateComponents()
        components.day = 7
        components.second = -1
        return Calendar.iso8601.date(byAdding: components, to: startOfWeek())!
    }
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.iso8601.date(byAdding: components, to: startOfMonth())!
    }
    var nextMonth: Date {
        var components = DateComponents()
        components.month = 1
        return Calendar.iso8601.date(byAdding: components, to: self)!
    }
    
    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar.iso8601.date(byAdding: components, to: startOfYear())!
    }
    func daysOfWeek(using calendar: Calendar = .iso8601) -> [Date] {
        let startOfWeek = self.startOfWeek(using: calendar).noon
        return (0...6).map { startOfWeek.byAdding(component: .day, value: $0, using: calendar)! }
    }
    
    func numberOfDaysInYear() -> Int {
        let calendar = Calendar.iso8601
        let interval = calendar.dateInterval(of: .year, for: self)!
        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        return days
    }
    
    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.iso8601
        let interval = calendar.dateInterval(of: .month, for: self)!
        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        return days
    }
    
    var ddMMyyyy: String { Formatter.ddMMyyyy.string(from: self) }
    
    var ddMMMMyyyy: String { Formatter.ddMMMMyyyy.string(from: self) }
    
    var ddMMMM: String { Formatter.ddMMMM.string(from: self) }
    
    var EE: String { Formatter.EE.string(from: self) }
}

extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Formatter {
    static let ddMMyyyy: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
    static let ddMMMMyyyy: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter
    }()
    
    static let ddMMMM: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd MMMM"
        return dateFormatter
    }()
    
    static let EE: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EE"
        return dateFormatter
    }()
}
