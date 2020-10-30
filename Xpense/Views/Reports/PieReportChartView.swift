//
//  MonthlyTransactionAmountChartView.swift
//  Xpense
//
//  Created by Teddy Santya on 30/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SwiftUICharts
import PartialSheet

struct ChartModel: Hashable {
    var category: CategoryModel
    var amount: Double
    var color: ColorGradient
    var transactions: [TransactionModel]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
}

struct PieReportChartView: View {
    
    var reportType: CategoryType
    var amountColor: Color {
        reportType == .expense ? Color(UIColor.systemRed) : Color(UIColor.systemGreen)
    }
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    @State var selectedDate = Date()
    @State var segmentIndex = 1
    var segments = ReportDatePickerType.allCases
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = segmentIndex == 0 ? "dd MMMM yyyy" : segmentIndex == 1 ? "MMMM yyyy" : "yyyy"
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Picker(selection: self.$segmentIndex, label: Text("")) {
                    ForEach(0..<self.segments.count) { index in
                        Text(self.segments[index].rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: self.segmentIndex, perform: { value in
                    self.segmentChanged(value)
                })
                ReportPieChartDetailView(fetchRequest: getFetchRequest(), elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod: getElapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod(), reportType: reportType, amountColor: amountColor)
            }
        }.navigationTitle(dateFormatter.string(from: selectedDate))
        .onAppear {
            setupCurrentMonth()
        }
        .navigationBarItems(trailing: HStack {
            Button(action: {
                self.partialSheetManager.showPartialSheet({
                        print("Partial sheet dismissed")
                    }) {
                    ReportDatePicker(dateSelection: $selectedDate, type: segments[segmentIndex])
                }
            }) {
                Image(systemSymbol: .calendar)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.2)
                    .padding()
            }
            Menu {
                Section {
                    Button(action: {
                        // Show By Category
                    }) {
                        Label {
                            Text("Show By Categories")
                        } icon: {
                            Image(systemSymbol: .rectangleStackFill)
                        }
                    }
                    Button(action: {
                        // Show By Payment Methods
                    }) {
                        Label {
                            Text("Show By Payment Methods")
                        } icon: {
                            Image(systemSymbol: .creditcard)
                        }
                    }
                }
            }
            label: {
                Image(systemSymbol: .lineHorizontal3DecreaseCircle)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.2)
                    .padding()
            }
        })
    }
    
    func setupCurrentMonth() {
        let date = Date()
        self.selectedDate = date
    }
    
    func getFetchRequest() -> FetchRequest<TransactionModel> {
        let dateType = segments[segmentIndex]
        switch dateType {
        case .day:
            return makeDailyTransactionAmountFetchRequest()
        case .month:
            return makeMonthlyTransactionAmountFetchRequest()
        default:
            return makeYearlyTransactionAmountFetchRequest()
        }
    }
    
    func makeDailyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let startOfDay = selectedDate.startOfDay
        let endOfDay = selectedDate.endOfDay
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let categoryType = reportType.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@", startOfDay as NSDate, endOfDay as NSDate, categoryType)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func makeMonthlyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let startOfMonth = selectedDate.startOfMonth()
        let endOfMonth = selectedDate.endOfMonth
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let categoryType = reportType.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@", startOfMonth as NSDate , endOfMonth as NSDate, categoryType)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func makeYearlyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let startOfYear = selectedDate.startOfYear()
        let endOfYear = selectedDate.endOfYear
        
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let categoryType = reportType.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@", startOfYear as NSDate, endOfYear as NSDate, categoryType)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func getElapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod() -> (Int, Bool, Int)? {
        let dateType = segments[segmentIndex]
        switch dateType {
        case .day:
            return nil
        case .month:
            let startOfMonth = selectedDate.startOfMonth()
            let components = Calendar.current.dateComponents([.day], from: startOfMonth, to: Date())
            let currentPeriodStartOfMonth = Date().startOfMonth()
            return (components.day ?? 0, currentPeriodStartOfMonth == startOfMonth, selectedDate.numberOfDaysInMonth())
        default:
            let startOfYear = selectedDate.startOfYear()
            let components = Calendar.current.dateComponents([.day], from: startOfYear, to: Date())
            let currentPeriodStartOfYear = Date().startOfYear()
            return (components.day ?? 0, currentPeriodStartOfYear == startOfYear, selectedDate.numberOfDaysInYear())
        }
    }
    func segmentChanged(_ segment: Int) {
        
    }
}

struct MonthlyTransactionAmountChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieReportChartView(reportType: .expense)
    }
}

private struct ReportPieChartDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<TransactionModel>
    private var data: FetchedResults<TransactionModel> {
        fetchRequest.wrappedValue
    }
    var elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod: (Int, Bool, Int)?
    var reportType: CategoryType
    var amountColor: Color
    
    var body: some View {
        let dataAndStyle = mapFetchResultIntoChartDataAndStyle(data)
        let listData = dataAndStyle.1
        let currency = listData.0.first?.transactions.first?.amount?.currencyValue.currency ?? ""
        let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
        if listData.0.count > 0 {
            VStack {
                Text("Total \(reportType.rawValue)")
                Text(CurrencyHelper.string(from: listData.1, currency: currencySign))
                    .font(.sectionTitle)
                    .foregroundColor(amountColor)
                PieChart()
                    .data(listData.0.map{$0.amount})
                    .chartStyle(dataAndStyle.0)
                    .padding()
                    .aspectRatio(CGSize(width: 1, height: 0.7), contentMode: .fit)
                ReportDetailListView(chartData: listData.0, totalAmount: listData.1, elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod: elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod, reportType: reportType, amountColor: amountColor).padding(.top)
            }.id(listData.0.count)
        }
        else {
            VStack {
                Text("No Data")
            }.frame(minHeight: 300)
        }
    }
    
    func mapFetchResultIntoChartDataAndStyle(_ result : FetchedResults<TransactionModel>)-> (ChartStyle, ([ChartModel], Double)) {
        var total: Double = 0.0
        let data = Dictionary(grouping: result){ (transaction : TransactionModel) -> CategoryModel in
            // group by category
            return transaction.category!
        }.values.map { (transactionByGroup) -> (ChartModel) in
            var totalTransactionAmountForGroup: Double = 0.0
            for transaction in transactionByGroup {
                let amountString: String = transaction.amount?.currencyValue.amount ?? "0"
                let amount: Double = Double(amountString)!
                totalTransactionAmountForGroup += amount
            }
            let category = transactionByGroup[0].category!
            let categoryColorData = category.color
            let categoryUIColor = UIColor.color(data: categoryColorData!)
            let colorGradient = ColorGradient(Color(categoryUIColor!))
            total += totalTransactionAmountForGroup
            return ChartModel(category: category, amount: totalTransactionAmountForGroup, color: colorGradient, transactions: transactionByGroup)
        }.sorted { (first, second) -> Bool in
            return first.amount > second.amount
        }
        
        let chartStyle = ChartStyle(backgroundColor: Color(UIColor.clear), foregroundColor: data.map{$0.color})
        return (chartStyle, (data, total))
    }
    
}

struct ReportDetailListView: View {
    
    var chartData: [ChartModel]
    var totalAmount: Double
    var elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod: (Int, Bool, Int)?
    var reportType: CategoryType
    var amountColor: Color
    
    var body: some View {
        VStack {
            let averages = getOverallAverageAndPerDayAndTotal()
            let averageTransaction = averages.2
            let averageDailyTransaction = averages.3
            HStack(alignment: .bottom, spacing: .medium) {
                VStack(alignment: .leading, spacing: .tiny) {
                    Text("")
                        .font(.footnote)
                    Text("Divided by")
                        .font(.footnote)
                    Text("Average")
                        .font(.footnote)
                }
                if averageTransaction > 0 {
                    VStack(alignment: .leading, spacing: .tiny) {
                        Text("Overall \(reportType.rawValue)")
                            .font(.footnote)
                        Text("\(averageTransaction) transaction(s)")
                            .font(.footnote)
                        Text(averages.0)
                            .font(.footnote).bold()
                            .foregroundColor(amountColor)
                    }
                }
                if averageDailyTransaction > 0 {
                    VStack(alignment: .leading, spacing: .tiny) {
                        Text("Daily \(reportType.rawValue)")
                            .font(.footnote)
                        Text("\(averageDailyTransaction) day(s)")
                            .font(.footnote)
                        Text(averages.1)
                            .font(.footnote).bold()
                            .foregroundColor(amountColor)
                    }
                }
                Spacer()
            }.padding()
            LazyVStack {
                ForEach(chartData, id: \.self) {
                    chartModel in
                    if let firstData = chartData.first {
                        let largestAmount = firstData.amount
                        let category = chartModel.category
                        let color = chartModel.color.startColor
                        let amount = chartModel.amount
                        let percentage = amount / totalAmount * 100
                        let decimals = percentage.truncatingRemainder(dividingBy: 1.0) == 0 ? 0 : 2
                        let percentageFormat = String(format: "%.\(decimals)f", percentage)
                        let percentageToShow = percentage < 1 ? "< 0" : percentageFormat
                        let transaction = firstData.transactions.first
                        let currency = transaction?.amount?.currencyValue.currency ?? ""
                        let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
                        VStack {
                            HStack(alignment: .top) {
                                CategoryIconDisplayView(category: category, iconWidth: 50.0, iconHeight: 50.0)
                                    .padding()
                                HStack {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Spacer()
                                        Text(category.name ?? "").font(.footnote)
                                        HStack(alignment: .bottom) {
                                            Text(CurrencyHelper.string(from: amount, currency: currencySign))
                                                .font(.header)
                                                .foregroundColor(amountColor)
                                            Spacer()
                                        }
                                        HStack {
                                            ProgressView(value: amount, total: largestAmount)
                                                .accentColor(color)
                                            Text("\(percentageToShow)%").font(.footnote)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                                .frame(minWidth: 50, alignment: .trailing)
                                        }
                                        .padding(.trailing, .extraLarge)
                                        Spacer()
                                    }
                                    Image(systemSymbol: .chevronRight)
                                        .padding(.trailing)
                                }
                            }
                            Divider()
                        }
                    }
                }
            }.background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    func getOverallAverageAndPerDayAndTotal() -> (String, String, Int, Int, String) {
        var transactionsCount = 0
        var totalAmount: Double = 0.0
        var currency = ""
        var totalDays: Int? = elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod?.2
        
        for data in chartData {
            for transaction in data.transactions {
                let amountString = transaction.amount?.currencyValue.amount ?? ""
                let amount = Double(amountString) ?? 0
                if transaction.category?.type == reportType.rawValue {
                    totalAmount += amount
                    transactionsCount += 1
                    if currency.count == 0 {
                        currency = CurrencyHelper.getCurrencySignFromCurrency(transaction.amount?.currencyValue.currency ?? "") ?? ""
                    }
                }
            }
            if let _ = totalDays {
                if elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod!.1 {
                    totalDays = elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod!.0
                }
            }
        }
        let averageAmountOfTheWeek = totalAmount / Double(transactionsCount)
        let averageAmountPerDay = totalAmount / Double(totalDays ?? 1)
        let averageAmountOfTheWeekString = CurrencyHelper.string(from: averageAmountOfTheWeek, currency: currency)
        let averageAmountPerDayString = CurrencyHelper.string(from: averageAmountPerDay, currency: currency)
        let totalAmountString = CurrencyHelper.string(from: totalAmount, currency: currency)
        return (averageAmountOfTheWeekString, averageAmountPerDayString, transactionsCount, totalDays ?? 0, totalAmountString)
    }
}
