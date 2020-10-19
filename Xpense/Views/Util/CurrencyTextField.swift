//
//  CurrencyTextView.swift
//  Xpense
//
//  Created by Teddy Santya on 11/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct CurrencyTextField: View {
    
    @Binding var amount: Double
    @State var amountInputText: String = ""
    @Binding var currency: CurrencyValue
    var currencySign: String {
        get {
            CurrencyHelper.getCurrencySignFromCurrency(self.currency.currency)!
        }
    }
    @State var latestInputText: String = ""
    var numberFormatter: NumberFormatter!
    var body: some View {
        TextField(CurrencyHelper.string(from: amount, currency: self.currencySign), text: self.$amountInputText)
            .keyboardType(.numberPad)
            .padding()
            .onChange(of: amountInputText, perform: { value in
                let amt = CurrencyHelper.getAmountFrom(formattedCurrencyString: value, currency: self.currencySign)
                guard let balanceAmount = amt else { return amountInputText = latestInputText }
                amount = balanceAmount
                if (balanceAmount > 0) {
                    amountInputText = CurrencyHelper.string(from: balanceAmount, currency: self.currencySign)
                    latestInputText = amountInputText
                }
                else {
                    amountInputText = ""
                    latestInputText = amountInputText
                }
            })
    }
    
    init(amount: Binding<Double>, currency: Binding<CurrencyValue>) {
        self._amount = amount
        self._currency = currency
    }
}
