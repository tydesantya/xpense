//
//  CurrencyValue.swift
//  Xpense
//
//  Created by Teddy Santya on 10/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation
class CurrencyValue: NSObject, NSSecureCoding {
    
    
    var amount: String
    var currency: String
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(amount, forKey: "amount")
        coder.encode(currency, forKey: "currency")
    }
    
    required convenience init?(coder: NSCoder) {
        let amount = coder.decodeObject(forKey: "amount") as! String
        let currency = coder.decodeObject(forKey: "currency") as! String
        
        self.init(amount: amount, currency: currency)
    }
    
    init(amount: String, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}
