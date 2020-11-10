//
//  TransactionListView.swift
//  Xpense
//
//  Created by Teddy Santya on 25/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import CoreData
import Firebase

private struct MonthlyTransaction: Hashable {
    var totalExpense: Double
    var totalIncome: Double
    var transactions: [TransactionModel]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(transactions)
    }
}

struct TransactionListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TransactionModel.date, ascending: false)])
    private var transactions: FetchedResults<TransactionModel>
    @State var refreshFlag = UUID()
    
    var body: some View {
        ScrollView {
            VStack {
                LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                    ForEach(update(transactions), id: \.self) {
                        (section: MonthlyTransaction) in
                        Section(header: TransactionListHeaderView(title: dateFormatter.string(from: section.transactions[0].date!))) {
                            HStack {
                                Label {
                                    Text(CurrencyHelper.string(from: section.totalIncome, currency: CurrencyHelper.getCurrencySignFromCurrency(transactions[0].amount?.currencyValue.currency ?? "") ?? ""))
                                } icon: {
                                    Image(systemSymbol: .plusCircleFill).foregroundColor(Color(.systemGreen))
                                }.foregroundColor(Color(.systemGreen))
                                .padding(.trailing)
                                Label {
                                    Text(CurrencyHelper.string(from: section.totalExpense, currency: CurrencyHelper.getCurrencySignFromCurrency(transactions[0].amount?.currencyValue.currency ?? "") ?? ""))
                                } icon: {
                                    Image(systemSymbol: .minusCircleFill).foregroundColor(Color(.systemRed))
                                }.foregroundColor(Color(.systemRed))
                                Spacer()
                            }.padding(.bottom, .small)
                            ForEach(section.transactions, id: \.self) { transaction in
                                TransactionCellView(transaction: transaction, refreshFlag: $refreshFlag)
                            }
                        }.textCase(nil)
                    }
                }.padding(.horizontal)
                
                .id(refreshFlag)
            }.navigationTitle("Transactions")
        }
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                "screenName": "Transaction List"
            ])
        }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private func update(_ result : FetchedResults<TransactionModel>)-> [MonthlyTransaction] {
        return Dictionary(grouping: result){ (transaction : TransactionModel) -> String in
            let monthYear = dateFormatter.string(from: transaction.date!)
            // group by date
            return monthYear
        }.values.map { (section) -> MonthlyTransaction in
            var income: Double = 0
            var expense: Double = 0
            
            for transaction in section {
                if let amount = transaction.amount?.currencyValue.amount {
                    if let amount = Double(amount) {
                        if transactionIsExpense(transaction) {
                            expense += amount
                        }
                        else {
                            income += amount
                        }
                    }
                }
            }
            return MonthlyTransaction(totalExpense: expense, totalIncome: income, transactions: section)
        }
    }
    
    func transactionIsExpense(_ transaction: TransactionModel) -> Bool {
        return transaction.category?.type == CategoryType.expense.rawValue
    }
    
}

struct TransactionListHeaderView: View {

    var title: String
    var body: some View {
        HStack {
            Text(title).font(.sectionTitle)
            Spacer()
        }.padding(.vertical)
        .background(Color(.systemBackground))
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
    }
}
