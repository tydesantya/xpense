//
//  WeeklyExpenseChartView.swift
//  Xpense
//
//  Created by Teddy Santya on 29/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import BarChart

private struct DailyTransaction: Hashable {
    
    var totalExpense: Double
    var totalIncome: Double
    var transactions: [TransactionModel]
    var date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(transactions)
    }
}

struct WeeklyExpenseChartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TransactionModel.date, ascending: false)], predicate: NSPredicate(format: "category.type == %@", CategoryType.expense.rawValue))
    private var transactions: FetchedResults<TransactionModel>
    
    let config = ChartConfiguration()
    @State var tabSelection: Int = 0
    @State var lastTabSelection: Int = 0
    @State var refreshFlag: UUID = UUID()
    @State private var activeData: [[Date : DailyTransaction]] = []
    var body: some View {
        ScrollView {
            VStack {
                ZStack(alignment: .bottom) {
                    TabView(selection: $tabSelection) {
                        let prevIndex = lastTabSelection + 1
                        if prevIndex < activeData.count {
                            getChartViewFromWeekMapping(activeData[prevIndex])
                                .tag(prevIndex)
                        }
                        if lastTabSelection < activeData.count {
                            getChartViewFromWeekMapping(activeData[lastTabSelection])
                                .tag(lastTabSelection)
                        }
                        let nextIndex = lastTabSelection - 1
                        if nextIndex < activeData.count && nextIndex >= 0 {
                            getChartViewFromWeekMapping(activeData[nextIndex])
                                .tag(nextIndex)
                        }
                    }.id(refreshFlag)
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                    .frame(height: 250)
                    .onChange(of: tabSelection) { (selection) in
                        if tabSelection != lastTabSelection {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                lastTabSelection = tabSelection
                                refreshFlag = UUID()
                            }
                        }
                    }
                    Rectangle().fill(Color(UIColor.systemBackground)).frame(width: 200, height: 25)
                }
                .padding(.top)
                if lastTabSelection < activeData.count {
                    WeeklyExpenseDetailView(weekMapping: activeData[lastTabSelection])
                }
            }
        }.id(transactions.count)
        .onAppear {
            activeData = update(transactions)
            refreshFlag = UUID()
        }
        .navigationTitle("Weekly Expense")
    }
    
    private func getChartViewFromWeekMapping(_ weekMapping: [Date: DailyTransaction]) -> CustomBarChartView {
        let config = ChartConfiguration()
        config.data.color = Color(UIColor.systemRed)
        return CustomBarChartView(weekMapping: weekMapping, config: config)
    }
    
    private func update(_ result : FetchedResults<TransactionModel>)-> [[Date : DailyTransaction]] {
        let dailyGrouping = Dictionary(grouping: result){ (transaction : TransactionModel) -> String in
            let date = Formatter.ddMMyyyy.string(from: transaction.date!)
            return date
        }.values.map { (section) -> DailyTransaction in
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
            let date = section[0].date!
            return DailyTransaction(totalExpense: expense, totalIncome: income, transactions: section, date: date)
        }
        
        let sortedDailyGrouping = dailyGrouping.sorted { (first, second) -> Bool in
            return first.date > second.date
        }
        
        var weeks: [[Date]] = [] // array of days
        var fullWeekGrouping: [[Date: DailyTransaction]] = []
        
        let weeklyGrouping = Dictionary(grouping: sortedDailyGrouping) { (dailyTransaction: DailyTransaction) -> [Date] in
            let week = dailyTransaction.date.daysOfWeek(using: .iso8601)
            if !weeks.contains(week) {
                weeks.append(week)
            }
            return week
        }
        
        for week in weeks {
            var weekData: [Date: DailyTransaction] = [:]
            if let weekTransactions = weeklyGrouping[week] {
                for day in week {
                    var dayTransaction = DailyTransaction(totalExpense: 0, totalIncome: 0, transactions: [], date: day)
                    for dailyTransaction in weekTransactions {
                        let date = dailyTransaction.date
                        if Calendar.iso8601.isDate(day, inSameDayAs: date) {
                            dayTransaction = dailyTransaction
                        }
                    }
                    weekData[day] = dayTransaction
                }
            }
            fullWeekGrouping.append(weekData)
        }
        
        return fullWeekGrouping
    }
    
    func transactionIsExpense(_ transaction: TransactionModel) -> Bool {
        return transaction.category?.type == CategoryType.expense.rawValue
    }
}

struct WeeklyExpenseChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyExpenseChartView()
    }
}


private struct CustomBarChartView: View {
    
    var weekMapping: [Date: DailyTransaction]
    var config: ChartConfiguration
    
    var body: some View {
        var expenseFound = false
        let arrayOfKeys = Array(weekMapping.keys).sorted(by: <)
        let param = arrayOfKeys.map { (date) -> ChartDataEntry in
            let dateString = Formatter.EE.string(from: date)
            let totalExpense = weekMapping[date]!.totalExpense
            if totalExpense > 0 {
                expenseFound = true
            }
            let dataEntry = ChartDataEntry(x: dateString, y: totalExpense)
            return dataEntry
        }
        let firstDay = arrayOfKeys.first?.todayShortFormat()
        let lastDay = arrayOfKeys.last?.todayShortFormat()
        
        VStack {
            HStack {
                Spacer()
                Text("\(firstDay ?? "") - \(lastDay ?? "")")
                    .font(.footnote).bold()
                    .padding(.horizontal, .large)
                Spacer()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                    .padding(.horizontal, .large)
                BarChartView(config: self.config)
                    .foregroundColor(.white)
                    .onAppear {
                        self.config.xAxis.labelsColor = Color(UIColor.label)
                        self.config.xAxis.ticksDash = [2, 4]
                        self.config.xAxis.ticksColor = Color(UIColor.secondarySystemBackground)
                        
                        self.config.yAxis.labelsColor = Color(UIColor.label)
                        self.config.yAxis.ticksDash = [4, 4]
                        self.config.yAxis.ticksColor = .gray
                        self.config.yAxis.formatter = { (value, decimals) in
                            return "\(CurrencyHelper.string(from: value, currency: ""))"
                        }
                        self.config.labelsCTFont = CTFontCreateWithName(("Helvetica" as CFString), 10, nil)
                        self.config.data.entries = param
                    }.padding(.horizontal, .extraLarge + .small)
                    .padding(.vertical, .small)
                if !expenseFound {
                    Text("No Expense on this range of date")
                }
            }
        }.padding(.bottom, .extraLarge)
    }
}

private struct WeeklyExpenseDetailView: View {
    
    var weekMapping: [Date: DailyTransaction]
    @State var refreshFlag = UUID()
    
    var body: some View {
        LazyVStack {
            let averages = getAverageAmountOfTheWeekAndPerDayAndTotal()
            HStack(alignment: .center) {
                Text("Total")
                Text(averages.4)
                    .font(.sectionTitle)
                    .foregroundColor(Color(UIColor.systemRed))
                Spacer()
            }
            .padding(.bottom)
            .offset(y: -.large)
            Divider()
                .offset(y: -.large)
            HStack(alignment: .bottom, spacing: .medium) {
                VStack(alignment: .leading, spacing: .tiny) {
                    Text("")
                        .font(.footnote)
                    Text("Divided by")
                        .font(.footnote)
                    Text("Average")
                        .font(.footnote)
                }
                VStack(alignment: .leading, spacing: .tiny) {
                    Text("Weekly Expense")
                        .font(.footnote)
                    Text("\(averages.2) transaction(s)")
                        .font(.footnote)
                    Text(averages.0)
                        .font(.footnote).bold()
                        .foregroundColor(Color(UIColor.systemRed))
                }
                VStack(alignment: .leading, spacing: .tiny) {
                    Text("Daily Expense")
                        .font(.footnote)
                    Text("\(averages.3) day(s)")
                        .font(.footnote)
                    Text(averages.1)
                        .font(.footnote).bold()
                        .foregroundColor(Color(UIColor.systemRed))
                }
                Spacer()
            }
            ForEach(Array(weekMapping.keys).sorted(by: <), id: \.self) {
                key in
                let day = key.dayFormat()
                let dayTransaction = weekMapping[key]!
                let transactions = dayTransaction.transactions
                let dayTotal = dayTransaction.totalExpense
                let dayTotalAmount = CurrencyHelper.string(from: dayTotal, currency: CurrencyHelper.getCurrencySignFromCurrency(transactions.first?.amount?.currencyValue.currency ?? "") ?? "")
                if transactions.count > 0 {
                    HStack {
                        Text(day).font(.sectionTitle)
                        Spacer()
                        Text(dayTotalAmount)
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                    .padding(.top)
                    ForEach(transactions) {
                        transaction in
                        TransactionCellView(transaction: transaction, refreshFlag: $refreshFlag)
                    }
                }
            }.id(refreshFlag)
        }
        .padding()
    }
    
    func getAverageAmountOfTheWeekAndPerDayAndTotal() -> (String, String, Int, Int, String) {
        var transactionsCount = 0
        var totalAmount: Double = 0.0
        let keys = Array(weekMapping.keys)
        var currency = ""
        var totalDays = keys.count
        for key in keys {
            let dayTransaction = weekMapping[key]!
            for transaction in dayTransaction.transactions {
                let amountString = transaction.amount?.currencyValue.amount ?? ""
                let amount = Double(amountString) ?? 0
                if transaction.category?.type == CategoryType.expense.rawValue {
                    totalAmount += amount
                    transactionsCount += 1
                    if currency.count == 0 {
                        currency = CurrencyHelper.getCurrencySignFromCurrency(transaction.amount?.currencyValue.currency ?? "") ?? ""
                    }
                }
            }
            if key.startOfWeek(using: .iso8601) == Date().startOfWeek(using: .iso8601) {
                totalDays = getElapsedDayOfThisWeek()
            }
        }
        let averageAmountOfTheWeek = totalAmount / Double(transactionsCount)
        let averageAmountPerDay = totalAmount / Double(totalDays)
        let averageAmountOfTheWeekString = CurrencyHelper.string(from: averageAmountOfTheWeek, currency: currency)
        let averageAmountPerDayString = CurrencyHelper.string(from: averageAmountPerDay, currency: currency)
        let totalAmountString = CurrencyHelper.string(from: totalAmount, currency: currency)
        return (averageAmountOfTheWeekString, averageAmountPerDayString, transactionsCount, totalDays, totalAmountString)
    }
    
    func getElapsedDayOfThisWeek() -> Int {
        let startOfWeek = Date().startOfWeek(using: .iso8601)
        let components = Calendar.current.dateComponents([.day], from: startOfWeek, to: Date())
        return components.day ?? 0
    }
}
