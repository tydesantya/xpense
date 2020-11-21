//
//  TransactionDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 29/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SPAlert
import Firebase

struct TransactionDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var navigationActive: Bool
    @ObservedObject var transaction: TransactionModel
    var category: CategoryModel? {
        transaction.category
    }
    @State var editTransaction = false
    @State var confirmationAlertShown = false
    @Binding var refreshFlag: UUID
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    HStack {
                        if let category = category {
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
                    }
                    Divider()
                        .padding(.bottom)
                    VStack(alignment: .leading, spacing: .small) {
                        HStack(alignment: .top) {
                            HStack {
                                Text("Notes")
                                    .multilineTextAlignment(.leading)
                                    .font(.callout)
                                Spacer()
                            }
                            .frame(width: 150)
                            if transaction.note?.count ?? 0 > 0 {
                                Text(transaction.note!)
                            }
                            else {
                                Text("No Notes")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        }
                        HStack(alignment: .top) {
                            HStack {
                                Text("Date/Time")
                                    .multilineTextAlignment(.leading)
                                    .font(.callout)
                                Spacer()
                            }.frame(width: 150)
                            if let date = transaction.date {
                                Text(date.mediumDateTimeFormat())
                            }
                        }
                        HStack(alignment: .top) {
                            HStack {
                                Text("Payment Method")
                                    .multilineTextAlignment(.leading)
                                    .font(.callout)
                                Spacer()
                            }.frame(width: 150)
                            if let paymentMethod = transaction.paymentMethod {
                                let width = CGFloat(150)
                                let height = CGFloat(80)
                                PaymentMethodCardView(paymentMethod: paymentMethod, selectedPaymentMethod: .constant(nil))
                                    .frame(width: width, height: height)
                            }
                        }
                    }.id(refreshFlag)
                    Divider().padding(.vertical)
                    Button(action: {
                        confirmationAlertShown.toggle()
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
                }
                .onAppear {
                    Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                        AnalyticsParameterScreenName: "Transaction Detail"
                    ])
                }
                .navigationTitle("Transaction Detail")
                .navigationBarItems(trailing: Button(action: {
                    editTransaction = true
                }, label: {
                    Text("Edit")
                }))
                .padding(.large)
                .sheet(isPresented: $editTransaction, content: {
                    AddExpenseView(showSheetView: $editTransaction, refreshFlag: $refreshFlag, selectedTransaction: transaction)
                        .environment(\.managedObjectContext, viewContext)
                })
                .alert(isPresented: $confirmationAlertShown, content: {
                    Alert(title: Text("Warning"), message: Text("Are you sure you want to delete this transaction ?"), primaryButton: .destructive(Text("Delete")) {
                        deleteSelectedTransaction()
                    }, secondaryButton: .cancel())
                })
            }
        }
        .padding(.top, 0.3)
    }
    
    func deleteSelectedTransaction() {
        Analytics.logEvent("delete_transaction", parameters: [
            "categoryName": transaction.category?.name ?? "",
            "date": Date().mediumDateTimeFormat(),
            "paymentMethodName": transaction.paymentMethod?.name ?? "",
            "categoryType": transaction.category?.type ?? ""
        ])
        if transaction.paymentMethod?.type != PaymentMethodType.creditCard.rawValue {
            revertTransactionPaymentMethodAmount(transaction)
        }
        if let budget = transaction.budget {
            let initialBudgetUsedAmount = budget.usedAmount!.toDouble()
            let newBudgetAmount = initialBudgetUsedAmount - transaction.amount!.toDouble()
            budget.usedAmount = getDisplayCurrencyValueFromAmount(amt: newBudgetAmount)
        }
        viewContext.delete(transaction)
        do {
            try viewContext.save()
            SPAlert.present(title: "Deleted", preset: .done)
            presentationMode.wrappedValue.dismiss()
        } catch let createError {
            print("Failed to delete transaction \(createError)")
        }
    }
    
    func revertTransactionPaymentMethodAmount(_ transaction: TransactionModel) {
        let amountString = transaction.amount?.currencyValue.amount ?? ""
        let amount = Double(amountString) ?? 0
        let initialAmountString: String = transaction.paymentMethod?.balance?.currencyValue.amount ?? ""
        let initialAmount = Double(initialAmountString) ?? 0
        let categoryType = CategoryType(rawValue: transaction.category?.type ?? "") ?? .expense
        let revertedAmount = categoryType == .expense ? initialAmount + amount : initialAmount - amount
        
        let balance = getDisplayCurrencyValueFromAmount(amt: revertedAmount)
        transaction.paymentMethod?.balance = balance
    }
    
    func getDisplayCurrencyValueFromAmount(amt: Double) -> DisplayCurrencyValue {
        let selectedPaymentMethod = transaction.paymentMethod
        let numOfDecimalPoint = selectedPaymentMethod?.balance?.numOfDecimalPoint
        let decimalSeparator = selectedPaymentMethod?.balance?.decimalSeparator
        let groupingSeparator = selectedPaymentMethod?.balance?.groupingSeparator
        let amountString = numOfDecimalPoint == 0 ? String(format: "%.0f", amt) : String(amt)
        let currency = CurrencyValue(amount: amountString, currency: selectedPaymentMethod?.balance?.currencyValue.currency ?? "")
        return DisplayCurrencyValue(currencyValue: currency, numOfDecimalPoint: numOfDecimalPoint ?? 0, decimalSeparator: decimalSeparator ?? ",", groupingSeparator: groupingSeparator ?? ".")
    }
}
