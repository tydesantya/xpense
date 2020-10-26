//
//  ChartsView.swift
//  Xpense
//
//  Created by Teddy Santya on 26/10/20.
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

struct ChartsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TransactionModel.date, ascending: false)])
    private var transactions: FetchedResults<TransactionModel>
    
    let config = ChartConfiguration()
    @State var tabSelection: Int = 0
    @State var lastTabSelection: Int = 0
    @State var refreshFlag: UUID = UUID()
    @State private var activeData: [[Date : DailyTransaction]] = []
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Weekly Expenses")
                        .font(.sectionTitle)
                        .padding()
                    Spacer()
                }
                ZStack(alignment: .bottom) {
                    TabView(selection: $tabSelection) {
                        let prevIndex = lastTabSelection + 1
                        if prevIndex < activeData.count {
                            getChartViewFromWeekMapping(activeData[prevIndex])
                                .tag(prevIndex)
                        }
                        if lastTabSelection < activeData.count {
                            getChartViewFromWeekMapping(activeData[tabSelection])
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
                HStack {
                    Text("Monthly Report")
                        .font(.sectionTitle)
                        .padding()
                    Spacer()
                }
            }
        }.id(transactions.count)
        .onAppear {
            activeData = update(transactions)
            refreshFlag = UUID()
        }
    }
    
    private func getChartViewFromWeekMapping(_ weekMapping: [Date: DailyTransaction]) {
        
    }
    
    private func getChartViewFromWeekMapping(_ weekMapping: [Date: DailyTransaction]) -> CustomBarChartView {
        let config = ChartConfiguration()
        config.data.color = .theme
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

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
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
                        self.config.yAxis.ticksDash = [2, 4]
                        self.config.yAxis.ticksColor = Color(UIColor.secondarySystemBackground)
                        self.config.yAxis.formatter = { (value, decimals) in
                            return ""
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
