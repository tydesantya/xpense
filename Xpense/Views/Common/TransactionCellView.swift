//
//  TransactionCellView.swift
//  Xpense
//
//  Created by Teddy Santya on 10/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SFSafeSymbols

struct TransactionCellView: View {
    
    var transaction: TransactionModel
    var category: CategoryModel {
        transaction.category!
    }
    
    var navigationDestination: ((AnyView?) -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom) {
            HStack(spacing: .medium) {
                ZStack {
                    let customTextIcon = category.text
                    let symbolSelection:SFSymbol = SFSymbol(rawValue: category.symbolName ?? "") ?? .archiveboxFill
                    Circle()
                        .fill(
                            LinearGradient(gradient: .init(colors: [Color(UIColor.color(data: category.lighterColor!)!), Color(UIColor.color(data: category.color!)!)]), startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 40, height: 40)
                    if let text = customTextIcon {
                        Text(text)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    else {
                        Image(systemSymbol: symbolSelection)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        .foregroundColor(.white)
                    }
                }
                VStack(alignment: .leading) {
                    Text(category.name ?? "")
                        .bold()
                    if category.type == CategoryType.income.rawValue {
                        Text(getTransactionAmount())
                            .font(.title)
                            .bold()
                            .foregroundColor(.init(.systemGreen))
                    }
                    else {
                        Text("-\(getTransactionAmount())")
                            .font(.title)
                            .bold()
                            .foregroundColor(.init(.systemRed))
                    }
                }
            }
            Spacer()
            HStack {
                Text(transaction.date?.todayShortFormat() ?? "")
                Image(systemSymbol: .chevronRight)
            }
            .foregroundColor(.init(.secondaryLabel))
            .font(.caption)
        }
        .padding()
        .background(
            Color.init(.secondarySystemBackground)
            .cornerRadius(16)
        )
        .onTapGesture {
            if let navigation = navigationDestination {
                navigation(generateDestinationView())
            }
        }
    }
    
    
    func getTransactionAmount() -> String {
        let amount: String = transaction.amount?.currencyValue.amount ?? "0"
        let transactionAmount = Double(amount) ?? 0
        let currency = transaction.amount?.currencyValue.currency ?? ""
        let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency)
        return CurrencyHelper.string(from: transactionAmount, currency: currencySign!)
    }
    
    func generateDestinationView() -> AnyView {
        return AnyView(SwiftUIView())
    }
}
