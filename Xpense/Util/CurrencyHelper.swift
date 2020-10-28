//
//  CurrencyHelper.swift
//  Xpense
//
//  Created by Teddy Santya on 11/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation
class CurrencyHelper {
    
    static func getNumberFormatterFor(_ currency: String, _ numOfDecimalPoints: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = numOfDecimalPoints
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        return formatter
    }
    
    static func getCurrencySignFromCurrency(_ currency: String) -> String? {
        let currencySignMap = [
            "IDR": "Rp"
        ]
        
        let value = currencySignMap[currency]
        return value
    }
    
    static func getAmountFrom(formattedCurrencyString: String, currency: String) -> Double? {
        var amountString = formattedCurrencyString.replacingOccurrences(of: currency, with: "")
        amountString = amountString.replacingOccurrences(of: ".", with: "")
        amountString = amountString.replacingOccurrences(of: ",", with: "")
        amountString = amountString.replacingOccurrences(of: " ", with: "")
        return amountString.count == 0 ? 0 : Double(amountString)
    }
    
    static func string(from value: Double, currency: String) -> String {
        let numberFormatter = getNumberFormatterFor("Rp", 0)
        guard let s = numberFormatter.string(from: NSNumber(value: value)) else { return "" }
        return "\(currency) \(s)"
    }
}
