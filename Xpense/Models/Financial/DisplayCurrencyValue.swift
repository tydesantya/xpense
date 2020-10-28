//
//  DisplayCurrencyValue.swift
//  Xpense
//
//  Created by Teddy Santya on 10/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation

public class DisplayCurrencyValue: NSObject, NSSecureCoding {
    var currencyValue: CurrencyValue
    var numOfDecimalPoint: Int
    var decimalSeparator: String
    var groupingSeparator: String
    
    public func encode(with coder: NSCoder) {
        coder.encode(currencyValue, forKey: "currencyValue")
        coder.encode(numOfDecimalPoint, forKey: "numOfDecimalPoint")
        coder.encode(decimalSeparator, forKey: "decimalSeparator")
        coder.encode(groupingSeparator, forKey: "groupingSeparator")
    }
    
    public required convenience init?(coder: NSCoder) {
        let numOfDecimalPoint = coder.decodeInteger(forKey: "numOfDecimalPoint")
        let currencyValue = coder.decodeObject(of: CurrencyValue.self, forKey: "currencyValue")
        let decimalSeparator = coder.decodeObject(forKey: "decimalSeparator") as! String
        let groupingSeparator = coder.decodeObject(forKey: "groupingSeparator") as! String
        
        self.init(currencyValue: currencyValue!, numOfDecimalPoint: numOfDecimalPoint, decimalSeparator: decimalSeparator, groupingSeparator: groupingSeparator)
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    init(currencyValue: CurrencyValue, numOfDecimalPoint: Int, decimalSeparator: String, groupingSeparator: String) {
        self.currencyValue = currencyValue
        self.numOfDecimalPoint = numOfDecimalPoint
        self.decimalSeparator = decimalSeparator
        self.groupingSeparator = groupingSeparator
    }
    
    func toString() -> String {
        let amountString = currencyValue.amount
        let amount = Double(amountString) ?? 0
        let currency = currencyValue.currency
        let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency)
        let string = CurrencyHelper.string(from: amount, currency: currencySign ?? "")
        return string
    }
}
