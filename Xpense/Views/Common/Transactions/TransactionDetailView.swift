//
//  TransactionDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 29/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct TransactionDetailView: View {
    
    var transaction: TransactionModel
    var category: CategoryModel {
        transaction.category!
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    HStack {
                        CategoryIconDisplayView(category: category, iconWidth: 100.0, iconHeight: 100.0)
                        VStack(alignment: .leading) {
                            Text(category.name!)
                                .font(.title)
                            let color = category.type == CategoryType.income.rawValue ? Color(UIColor.systemGreen) : Color(UIColor.systemRed)
                            Text(transaction.amount!.toString())
                                .font(.huge)
                                .foregroundColor(color)
                        }
                        .padding(.leading, .medium)
                        Spacer()
                    }
                    Divider()
                        .padding(.bottom)
                    HStack(alignment: .top, spacing: .medium) {
                        VStack(alignment: .leading, spacing: .small) {
                            Text("Notes")
                            Text("Date/Time")
                            Text("Payment Method")
                        }
                        VStack(alignment: .leading, spacing: .small) {
                            if transaction.note!.count > 0 {
                                Text(transaction.note!)
                            }
                            else {
                                Text("No Notes")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            Text(transaction.date!.dateTimeFormat())
                            let width = CGFloat(150)
                            let height = CGFloat(80)
                            PaymentMethodCardView(paymentMethod: transaction.paymentMethod!, selectedPaymentMethod: .constant(nil))
                                .frame(width: width, height: height)
                        }
                        Spacer()
                    }
                    Divider().padding(.vertical)
                    Button(action: {
                        
                    }, label: {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemRed))
                                .frame(width: 50, height: 50)
                                .padding()
                            Image(systemSymbol: .trash)
                                .foregroundColor(.white)
                        }
                    })
                    Spacer()
                }.navigationTitle("Transaction Detail")
                .padding(.large)
            }
        }
    }
}
