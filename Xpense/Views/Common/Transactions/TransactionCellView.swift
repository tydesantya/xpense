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
    var category: CategoryModel? {
        transaction.category
    }
    var paymentMethod: PaymentMethod? {
        transaction.paymentMethod
    }
    var topUpSource: TopUp? {
        transaction.topUpSource
    }
    var topUpTarget: TopUp? {
        transaction.topUpTarget
    }
    @State var navigationActive = false
    @Binding var refreshFlag: UUID
    var editable: Bool = true
    
    var body: some View {
        NavigationLink(
            destination: TransactionDetailView(navigationActive: $navigationActive, transaction: transaction, refreshFlag: $refreshFlag),
            isActive: $navigationActive,
            label: {
                HStack {
                    if let category = category {
                        HStack(spacing: .medium) {
                            CategoryIconDisplayView(category: category, iconWidth: 40.0, iconHeight: 40.0)
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
                    }
                    if let topUpSource = topUpSource {
                        HStack(spacing: .medium) {
                            TopUpIconDisplayView(iconWidth: 40, iconHeight: 40, uiColor: .systemGreen)
                            VStack(alignment: .leading) {
                                Text(topUpSource.topUpSource?.paymentMethod?.name ?? "")
                                    .foregroundColor(.init(.label))
                                    .bold()
                                Text(getTransactionAmount())
                                    .font(.header)
                                    .foregroundColor(.init(.systemGreen))
                            }
                        }
                    }
                    
                    if let target = topUpTarget {
                        HStack(spacing: .medium) {
                            TopUpIconDisplayView(iconWidth: 40, iconHeight: 40, uiColor: .systemRed)
                            VStack(alignment: .leading) {
                                Text(target.topUpTarget?.paymentMethod?.name ?? "")
                                    .foregroundColor(.init(.label))
                                    .bold()
                                Text("-\(getTransactionAmount())")
                                    .font(.header)
                                    .foregroundColor(.init(.systemRed))
                            }
                        }
                    }
                    Spacer()
                    if let paymentMethod = paymentMethod {
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
                                if editable {
                                    Image(systemSymbol: .chevronRight)
                                }
                            }.padding(.top, .tiny)
                        }
                        .foregroundColor(.init(.secondaryLabel))
                        .font(.caption)
                    }
                }
                .padding()
                .background(
                    Color.init(.secondarySystemBackground)
                        .cornerRadius(16)
                )
            }
        ).allowsHitTesting(editable)
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
