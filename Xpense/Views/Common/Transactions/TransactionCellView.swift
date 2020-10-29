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
    var paymentMethod: PaymentMethod {
        transaction.paymentMethod!
    }
    @State var navigationActive = false
    @Binding var refreshFlag: UUID
    
    var body: some View {
        NavigationLink(
            destination: TransactionDetailView(navigationActive: $navigationActive, transaction: transaction, refreshFlag: $refreshFlag),
            isActive: $navigationActive,
            label: {
                HStack {
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
                                .foregroundColor(.init(.label))
                                .bold()
                            if category.type == CategoryType.income.rawValue {
                                Text(getTransactionAmount())
                                    .font(.header)
                                    .foregroundColor(.init(.systemGreen))
                            }
                            else {
                                Text("-\(getTransactionAmount())")
                                    .font(.header)
                                    .foregroundColor(.init(.systemRed))
                            }
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(paymentMethod.name ?? "")
                            .font(.footnote)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, .tiny)
                            .background(Capsule().fill(Color(UIColor.color(data: paymentMethod.color!)!)))
                        Spacer()
                        HStack {
                            Text(transaction.date?.todayShortFormat() ?? "")
                            Image(systemSymbol: .chevronRight)
                        }.padding(.top, .tiny)
                    }
                    .foregroundColor(.init(.secondaryLabel))
                    .font(.caption)
                }
                .padding()
                .background(
                    Color.init(.secondarySystemBackground)
                        .cornerRadius(16)
                )
            })
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
