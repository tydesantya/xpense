//
//  ReportsView.swift
//  Xpense
//
//  Created by Teddy Santya on 28/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SFSafeSymbols

struct ReportsView: View {
    
    @State var navigate: Bool = false
    @State var destinationView: AnyView?
    
    @Environment(\.managedObjectContext) private var viewContext
    var weeklyExpenseFetchRequest: FetchRequest<TransactionModel>
    var weeklyExpenseTransactions : FetchedResults<TransactionModel>{weeklyExpenseFetchRequest.wrappedValue}
    
    var monthlyIncomeFetchRequest: FetchRequest<TransactionModel>
    var monthlyIncomeTransactions : FetchedResults<TransactionModel>{monthlyIncomeFetchRequest.wrappedValue}
    
    var monthlyExpenseFetchRequest: FetchRequest<TransactionModel>
    var monthlyExpenseTransactions : FetchedResults<TransactionModel>{monthlyExpenseFetchRequest.wrappedValue}
    
    var body: some View {
        if monthlyExpenseTransactions.count == 0 && monthlyIncomeTransactions.count == 0 {
            VStack {
                Text("No Transactions")
            }
        }
        else {
            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Transactions")
                            .padding(.top)
                            .font(.sectionTitle)
                        if weeklyExpenseTransactions.count > 0 {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "chart.bar.xaxis")
                                        .foregroundColor(Color(UIColor.systemRed))
                                    Text("Weekly Expense")
                                        .foregroundColor(Color(UIColor.systemRed))
                                    Spacer()
                                    Text(getLatestExpenseTransactionDateTimeThisWeek())
                                        .font(.caption)
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                    Image(systemSymbol: .chevronRight)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                Divider()
                                Text(getTotalExpenseTransactionThisWeek()).font(.header)
                                Text("Total Expense This Week").font(.footnote)
                                    .padding(.top, .tiny)
                            }
                            .padding()
                            .background(
                                Color.init(.secondarySystemBackground)
                                    .cornerRadius(.medium)
                            )
                            .onTapGesture {
                                destinationView = AnyView(WeeklyExpenseChartView())
                                navigate = true
                            }
                        }
                        let totalIncomeThisMonth = getTotalIncomeThisMonth()
                        if monthlyIncomeTransactions.count > 0 {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "chart.pie.fill")
                                        .foregroundColor(Color(UIColor.systemGreen))
                                    Text("Income Report")
                                        .foregroundColor(Color(UIColor.systemGreen))
                                    Spacer()
                                    Text(getLatestIncomeTransactionDateTimeThisMonth())
                                        .font(.caption)
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                    Image(systemSymbol: .chevronRight)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                Divider()
                                Text(totalIncomeThisMonth).font(.header)
                                Text("Total Income This Month").font(.footnote)
                                    .padding(.top, .tiny)
                            }.padding()
                            .background(
                                Color.init(.secondarySystemBackground)
                                    .cornerRadius(.medium)
                            )
                            .onTapGesture {
                                destinationView = AnyView(PieReportChartView(reportType: .income))
                                navigate.toggle()
                            }
                        }
                        let totalExpenseThisMonth = getTotalExpenseThisMonth()
                        if monthlyExpenseTransactions.count > 0 {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "chart.pie.fill")
                                        .foregroundColor(Color(UIColor.systemRed))
                                    Text("Expense Report")
                                        .foregroundColor(Color(UIColor.systemRed))
                                    Spacer()
                                    Text(getLatestExpenseTransactionDateTimeThisMonth())
                                        .font(.caption)
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                    Image(systemSymbol: .chevronRight)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                Divider()
                                Text(totalExpenseThisMonth).font(.header)
                                Text("Total Expense This Month").font(.footnote)
                                    .padding(.top, .tiny)
                            }.padding()
                            .background(
                                Color.init(.secondarySystemBackground)
                                    .cornerRadius(.medium)
                            )
                            .onTapGesture {
                                destinationView = AnyView(PieReportChartView(reportType: .expense))
                                navigate.toggle()
                            }
                        }
                        HStack {
                            Text("Highlights")
                                .font(.sectionTitle)
                            Spacer()
                        }.padding(.top)
                        let largestWeeklyExpenseTuple = getLargestWeeklyExpense()
                        if weeklyExpenseTransactions.count > 0 {
                            WeeklyHighlightReportView(largestWeeklyExpenseTuple: largestWeeklyExpenseTuple, elapsedDayOfThisWeek: getElapsedDayOfThisWeek(), averageWeeklyExpense: getAverageWeeklyExpense())
                        }
                        let largestMonthlyExpenseTuple = getLargestMonthlyExpense()
                        if monthlyExpenseTransactions.count > 0 {
                            MonthlyHighlightReportView(largestWeeklyExpenseTuple: largestWeeklyExpenseTuple, largestMonthlyExpenseTuple: largestMonthlyExpenseTuple, largestMonthlyIncomeTuple: getLargestMonthlyIncome(), totalMonthlyIncome: totalIncomeThisMonth, totalMonthlyExpense: totalExpenseThisMonth)
                        }
                    }.padding(.horizontal)
                    NavigationLink(
                        destination: destinationView,
                        isActive: self.$navigate,
                        label: {
                            EmptyView()
                        })
                }
            }
        }
    }
    
    func getTotalExpenseTransactionThisWeek() -> String {
        var amount: Double = 0.0
        var currencySign = ""
        for transaction in weeklyExpenseTransactions {
            let amountString = transaction.amount?.currencyValue.amount ?? "0"
            let currencyString = transaction.amount?.currencyValue.currency ?? ""
            amount += Double(amountString) ?? 0
            if currencySign.count == 0 {
                currencySign = CurrencyHelper.getCurrencySignFromCurrency(currencyString) ?? ""
            }
        }
        return CurrencyHelper.string(from: amount, currency: currencySign)
    }
    
    func getLatestExpenseTransactionDateTimeThisWeek() -> String {
        let latestTransaction = weeklyExpenseTransactions.last
        if let transaction = latestTransaction {
            let date = transaction.date
            return date!.dateTimeFormat()
        }
        return ""
    }
    
    func getTotalIncomeThisMonth() -> String {
        var amount: Double = 0.0
        var currencySign = ""
        for transaction in monthlyIncomeTransactions {
            let amountString = transaction.amount?.currencyValue.amount ?? "0"
            let currencyString = transaction.amount?.currencyValue.currency ?? ""
            amount += Double(amountString) ?? 0
            if currencySign.count == 0 {
                currencySign = CurrencyHelper.getCurrencySignFromCurrency(currencyString) ?? ""
            }
        }
        return CurrencyHelper.string(from: amount, currency: currencySign)
    }
    
    func getLatestIncomeTransactionDateTimeThisMonth() -> String {
        let latestTransaction = monthlyIncomeTransactions.last
        if let transaction = latestTransaction {
            let date = transaction.date
            return date!.dateTimeFormat()
        }
        return ""
    }
    
    func getTotalExpenseThisMonth() -> String {
        var amount: Double = 0.0
        var currencySign = ""
        for transaction in monthlyExpenseTransactions {
            let amountString = transaction.amount?.currencyValue.amount ?? "0"
            let currencyString = transaction.amount?.currencyValue.currency ?? ""
            amount += Double(amountString) ?? 0
            if currencySign.count == 0 {
                currencySign = CurrencyHelper.getCurrencySignFromCurrency(currencyString) ?? ""
            }
        }
        return CurrencyHelper.string(from: amount, currency: currencySign)
    }
    
    func getLatestExpenseTransactionDateTimeThisMonth() -> String {
        let latestTransaction = monthlyExpenseTransactions.last
        if let transaction = latestTransaction {
            let date = transaction.date
            return date!.dateTimeFormat()
        }
        return ""
    }
    
    func getLargestWeeklyExpense() -> (String, TransactionModel?) {
        var amount: Double = 0.0
        var currencySign = ""
        var largestTransaction: TransactionModel?
        for transaction in weeklyExpenseTransactions {
            let amountString = transaction.amount?.currencyValue.amount ?? "0"
            let currencyString = transaction.amount?.currencyValue.currency ?? ""
            let transactionAmount = Double(amountString) ?? 0
            amount = max(amount, transactionAmount)
            if (amount == transactionAmount) {
                largestTransaction = transaction
            }
            if currencySign.count == 0 {
                currencySign = CurrencyHelper.getCurrencySignFromCurrency(currencyString) ?? ""
            }
        }
        return (CurrencyHelper.string(from: amount, currency: currencySign), largestTransaction)
    }
    
    func getLargestMonthlyExpense() -> (String, TransactionModel?) {
        var amount: Double = 0.0
        var currencySign = ""
        var largestTransaction: TransactionModel?
        for transaction in monthlyExpenseTransactions {
            let amountString = transaction.amount?.currencyValue.amount ?? "0"
            let currencyString = transaction.amount?.currencyValue.currency ?? ""
            let transactionAmount = Double(amountString) ?? 0
            amount = max(amount, transactionAmount)
            if (amount == transactionAmount) {
                largestTransaction = transaction
            }
            if currencySign.count == 0 {
                currencySign = CurrencyHelper.getCurrencySignFromCurrency(currencyString) ?? ""
            }
        }
        return (CurrencyHelper.string(from: amount, currency: currencySign), largestTransaction)
    }
    
    func getLargestMonthlyIncome() -> (String, TransactionModel?) {
        var amount: Double = 0.0
        var currencySign = ""
        var largestTransaction: TransactionModel?
        for transaction in monthlyIncomeTransactions {
            let amountString = transaction.amount?.currencyValue.amount ?? "0"
            let currencyString = transaction.amount?.currencyValue.currency ?? ""
            let transactionAmount = Double(amountString) ?? 0
            amount = max(amount, transactionAmount)
            if (amount == transactionAmount) {
                largestTransaction = transaction
            }
            if currencySign.count == 0 {
                currencySign = CurrencyHelper.getCurrencySignFromCurrency(currencyString) ?? ""
            }
        }
        return (CurrencyHelper.string(from: amount, currency: currencySign), largestTransaction)
    }
    
    func getAverageWeeklyExpense() -> String {
        var amount: Double = 0.0
        var currencySign = ""
        for transaction in weeklyExpenseTransactions {
            let amountString = transaction.amount?.currencyValue.amount ?? "0"
            let currencyString = transaction.amount?.currencyValue.currency ?? ""
            amount += Double(amountString) ?? 0
            if currencySign.count == 0 {
                currencySign = CurrencyHelper.getCurrencySignFromCurrency(currencyString) ?? ""
            }
        }
        let average = amount / Double(weeklyExpenseTransactions.count)
        return CurrencyHelper.string(from: average, currency: currencySign)
    }
    
    func getElapsedDayOfThisWeek() -> String {
        let startOfWeek = Date().startOfWeek(using: .iso8601)
        let components = Calendar.iso8601.dateComponents([.day], from: startOfWeek, to: Date())
        return String(components.day ?? 0)
    }
    
    init() {
        // weekly income
        let startOfWeek = Date().startOfWeek(using: .iso8601)
        let endOfWeek = Date().endOfWeek
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let expenseType = CategoryType.expense.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@", startOfWeek as NSDate , endOfWeek as NSDate, expenseType)
        weeklyExpenseFetchRequest = FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
        
        
        let startOfMonth = Date().startOfMonth(using: .iso8601)
        let endOfMonth = Date().endOfMonth
        let incomeType = CategoryType.income.rawValue
        let monthlyIncomePredicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@", startOfMonth as NSDate , endOfMonth as NSDate, incomeType)
        monthlyIncomeFetchRequest = FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: monthlyIncomePredicate, animation: .spring())
        
        let monthlyExpensePredicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@", startOfMonth as NSDate , endOfMonth as NSDate, expenseType)
        monthlyExpenseFetchRequest = FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: monthlyExpensePredicate, animation: .spring())
    }
}

private struct WeeklyHighlightReportView: View {
    
    var largestWeeklyExpenseTuple: (String, TransactionModel?)
    var elapsedDayOfThisWeek: String
    var averageWeeklyExpense: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .medium)
                .fill(Color(UIColor.secondarySystemBackground))
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Text("Weekly")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                }
                Divider()
                Text("Over the last \(elapsedDayOfThisWeek) day(s) of this week, you spent an average of \(averageWeeklyExpense)").fixedSize(horizontal: false, vertical: true).padding(.bottom, .tiny)
                    .font(.footnote)
                Text("The largest expense amount is \(largestWeeklyExpenseTuple.0) from")
                    .font(.footnote)
                let transaction = largestWeeklyExpenseTuple.1
                let category = transaction!.category!
                let customTextIcon = category.text
                let symbolSelection:SFSymbol = SFSymbol(rawValue: category.symbolName ?? "") ?? .archiveboxFill
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(gradient: .init(colors: [Color(UIColor.color(data: category.lighterColor!)!), Color(UIColor.color(data: category.color!)!)]), startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 20, height: 20)
                        if let text = customTextIcon {
                            Text(text)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        else {
                            Image(systemSymbol: symbolSelection)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.white)
                            .foregroundColor(.white)
                        }
                    }
                    Text("\(category.name ?? ""): \(transaction!.date!.dateTimeFormat())").font(.footnote)
                }
            }.padding()
        }
    }
}

private struct MonthlyHighlightReportView: View {
    
    var largestWeeklyExpenseTuple: (String, TransactionModel?)
    var largestMonthlyExpenseTuple: (String, TransactionModel?)
    var largestMonthlyIncomeTuple: (String, TransactionModel?)
    var totalMonthlyIncome: String
    var totalMonthlyExpense: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .medium)
                .fill(Color(UIColor.secondarySystemBackground))
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Text("Monthly")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                }
                Divider()
                if let transaction = largestMonthlyIncomeTuple.1 {
                    if let largestIncomeCategory = transaction.category {
                        let largestIncomeTransaction = largestWeeklyExpenseTuple.1
                        Text("You earned a total of \(totalMonthlyIncome) this month").fixedSize(horizontal: false, vertical: true).padding(.bottom, .tiny)
                            .font(.footnote)
                        Text(largestMonthlyIncomeTuple.0 == totalMonthlyIncome ? "Purely from a single income from " : "Highlighting the largest income of the month from").fixedSize(horizontal: false, vertical: true).font(.footnote)
                        HStack {
                            CategoryIconDisplayView(category: largestIncomeCategory, iconWidth: 20, iconHeight: 20)
                            Text("\(largestIncomeCategory.name ?? ""): \(largestIncomeTransaction!.date!.dateTimeFormat())").font(.footnote)
                        }
                        if largestWeeklyExpenseTuple == largestMonthlyExpenseTuple {
                            Text("While the largest expense of this month is the same largest expense of this week").fixedSize(horizontal: false, vertical: true).padding(.bottom, .tiny)
                                .font(.footnote)
                        }
                        else {
                            Text("While largest expense amount is \(largestMonthlyExpenseTuple.0) from")
                                .font(.footnote)
                            let transaction = largestMonthlyExpenseTuple.1
                            let category = transaction!.category!
                            HStack {
                                CategoryIconDisplayView(category: category, iconWidth: 20, iconHeight: 20)
                                Text("\(category.name ?? ""): \(transaction!.date!.dateTimeFormat())").font(.footnote)
                            }
                        }
                        let income = CurrencyHelper.getAmountFrom(formattedCurrencyString: totalMonthlyIncome, currency: "Rp ")
                        let expense = CurrencyHelper.getAmountFrom(formattedCurrencyString: totalMonthlyExpense, currency: "Rp ")
                        if let income = income, let expense = expense {
                            let net  = income - expense
                            Text("You have a net balance of \(CurrencyHelper.string(from: net, currency: "Rp")) this month").font(.footnote)
                        }
                    }
                }
            }.padding()
        }
    }
}
struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}
