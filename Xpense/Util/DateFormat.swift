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
}
