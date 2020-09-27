//
//  Util.swift
//  Covid-ID
//
//  Created by Teddy Santya on 1/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation

final class Util {
    static func dateFromString(dateString: String, format: String) -> Date {
        let dateFormatter = Util.dateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    static func dateFromMiliseconds(miliseconds: Int, format: String) -> Date {
        let date = Date(timeIntervalSince1970: Double(miliseconds) / 1000.0)
        let dateFormatter = DateFormatter()
        return dateFromString(dateString: dateFormatter.string(from: date), format: format)
    }
    
    static func formattedDateFromMiliseconds(miliseconds: Int, format: String) -> String {
        let date = dateFromMiliseconds(miliseconds: miliseconds, format: format)
        let dateFormatter = Util.dateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    static func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_id")
        return dateFormatter
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension Array where Element : Equatable {

  public mutating func mergeElements<C : Collection>(newElements: C) where C.Iterator.Element == Element{
    let filteredList = newElements.filter({!self.contains($0)})
    self.append(contentsOf: filteredList)
  }

}

