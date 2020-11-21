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
import Firebase

struct ChartModel: Hashable {
    var category: CategoryModel?
    var paymentMethod: PaymentMethod?
    var amount: Double
    var color: ColorGradient
    var transactions: [TransactionModel]
    var groupingType: ReportGroupingType
    var periodString: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
}

enum ReportGroupingType {
    case categories
    case paymentMethods
}

struct PieReportChartView: View {
    
    var reportType: CategoryType
    var amountColor: Color {
        reportType == .expense ? Color(UIColor.systemRed) : Color(UIColor.systemGreen)
    }
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    @State var selectedDate = Date()
    @State var segmentIndex = 1
    @State var groupingType: ReportGroupingType = .categories
    @State var refreshFlag: UUID = UUID()
    @State var showTopUp: Bool = false
    
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
                ReportPieChartDetailView(fetchRequest: getFetchRequest(), elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod: getElapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod(), reportType: reportType, amountColor: amountColor, groupingType: groupingType, calculateNetBalance: reportType == .income, expenseFetchRequestForNetCalculation: getOppositeFetchRequest(), periodString: dateFormatter.string(from: selectedDate), refreshFlag: $refreshFlag)
            }.id(refreshFlag)
        }.navigationTitle(dateFormatter.string(from: selectedDate))
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                AnalyticsParameterScreenName: "Pie Report",
                "categoryType": reportType.rawValue
            ])
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
                        groupingType = .categories
                    }) {
                        Label {
                            Text("Show By Categories")
                        } icon: {
                            Image(systemSymbol: .rectangleStackFill)
                        }
                    }
                    Button(action: {
                        // Show By Payment Methods
                        groupingType = .paymentMethods
                    }) {
                        Label {
                            Text("Show By Payment Methods")
                        } icon: {
                            Image(systemSymbol: .creditcard)
                        }
                    }
                }
                Section {
                    Button(action: {
                        // Show By Category
                        showTopUp = false
                    }) {
                        Label {
                            Text("Exclude Top Ups")
                        } icon: {
                            if !showTopUp {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            else {
                                EmptyView()
                            }
                        }
                    }
                    Button(action: {
                        // Show By Category
                        showTopUp = true
                    }) {
                        Label {
                            Text("Include Top Ups")
                        } icon: {
                            if showTopUp {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            else {
                                EmptyView()
                            }
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
    
    func getOppositeFetchRequest() -> FetchRequest<TransactionModel> {
        let dateType = segments[segmentIndex]
        switch dateType {
        case .day:
            return makeOppositeDailyTransactionAmountFetchRequest()
        case .month:
            return makeOppositeMonthlyTransactionAmountFetchRequest()
        default:
            return makeOppositeYearlyTransactionAmountFetchRequest()
        }
    }
    
    func makeDailyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let startOfDay = selectedDate.startOfDay
        let endOfDay = selectedDate.endOfDay
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let categoryType = reportType.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@ && category.shouldHide == %@", startOfDay as NSDate, endOfDay as NSDate, categoryType, NSNumber(booleanLiteral: showTopUp))
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func makeMonthlyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let startOfMonth = selectedDate.startOfMonth()
        let endOfMonth = selectedDate.endOfMonth
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let categoryType = reportType.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@ && category.shouldHide == %@", startOfMonth as NSDate , endOfMonth as NSDate, categoryType, NSNumber(booleanLiteral: showTopUp))
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func makeYearlyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let startOfYear = selectedDate.startOfYear()
        let endOfYear = selectedDate.endOfYear
        
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let categoryType = reportType.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@ && category.shouldHide == %@", startOfYear as NSDate, endOfYear as NSDate, categoryType, NSNumber(booleanLiteral: showTopUp))
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func makeOppositeDailyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let categoryType = reportType.rawValue
        let startOfDay = selectedDate.startOfDay
        let endOfDay = selectedDate.endOfDay
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type != %@", startOfDay as NSDate, endOfDay as NSDate, categoryType)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func makeOppositeMonthlyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let startOfMonth = selectedDate.startOfMonth()
        let endOfMonth = selectedDate.endOfMonth
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let categoryType = reportType.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type != %@", startOfMonth as NSDate , endOfMonth as NSDate, categoryType)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func makeOppositeYearlyTransactionAmountFetchRequest() -> FetchRequest<TransactionModel> {
        let startOfYear = selectedDate.startOfYear()
        let endOfYear = selectedDate.endOfYear
        
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let categoryType = reportType.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type != %@", startOfYear as NSDate, endOfYear as NSDate, categoryType)
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
    var groupingType: ReportGroupingType
    
    var calculateNetBalance: Bool
    var expenseFetchRequestForNetCalculation: FetchRequest<TransactionModel>
    private var expenseDataForNetCalculation: FetchedResults<TransactionModel> {
        expenseFetchRequestForNetCalculation.wrappedValue
    }
    var periodString: String
    @Binding var refreshFlag: UUID
    
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
                ReportDetailListView(chartData: listData.0, totalAmount: listData.1, elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod: elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod, reportType: reportType, amountColor: amountColor, groupingType: groupingType, oppositeTotalAmount: getTotalOppositeAmount(expenseDataForNetCalculation), calculateNetBalance: calculateNetBalance, refreshFlag: $refreshFlag).padding(.top)
            }.id(listData.0.count)
        }
        else {
            VStack {
                Text("No Data")
            }.frame(minHeight: 300)
        }
    }
    
    func getTotalOppositeAmount(_ result : FetchedResults<TransactionModel>) -> Double {
        if !calculateNetBalance {
            return 0.0
        }
        var total: Double = 0.0
        for transaction in result {
            let amountString = transaction.amount?.currencyValue.amount ?? "0"
            let amount = Double(amountString) ?? 0
            total += amount
        }
        return total
    }
    
    func mapFetchResultIntoChartDataAndStyle(_ result : FetchedResults<TransactionModel>)-> (ChartStyle, ([ChartModel], Double)) {
        var total: Double = 0.0
        var data: [ChartModel] = []
        if groupingType == .paymentMethods {
            data = Dictionary(grouping: result) { (transaction: TransactionModel) -> PaymentMethod in
                // group by payment method
                return transaction.paymentMethod!
            }.values.map { (transactionByPaymentMethod) -> ChartModel in
                var totalTransactionAmountForPaymentMethod: Double = 0.0
                for transaction in transactionByPaymentMethod {
                    let amountString: String = transaction.amount?.currencyValue.amount ?? "0"
                    let amount: Double = Double(amountString)!
                    totalTransactionAmountForPaymentMethod += amount
                }
                let paymentMethod = transactionByPaymentMethod[0].paymentMethod!
                let paymentMethodColorData = paymentMethod.color
                let paymentMethodUIColor = UIColor.color(data: paymentMethodColorData!)
                let colorGradient = ColorGradient(Color(paymentMethodUIColor!))
                total += totalTransactionAmountForPaymentMethod
                return ChartModel(paymentMethod: paymentMethod, amount: totalTransactionAmountForPaymentMethod, color: colorGradient, transactions: transactionByPaymentMethod, groupingType: groupingType, periodString: periodString)
            }
        }
        else {
            data = Dictionary(grouping: result){ (transaction : TransactionModel) -> CategoryModel in
                // group by category
                return transaction.category!
            }.values.map { (transactionByCategory) -> ChartModel in
                var totalTransactionAmountForCategory: Double = 0.0
                for transaction in transactionByCategory {
                    let amountString: String = transaction.amount?.currencyValue.amount ?? "0"
                    let amount: Double = Double(amountString)!
                    totalTransactionAmountForCategory += amount
                }
                let category = transactionByCategory[0].category!
                let categoryColorData = category.color
                let categoryUIColor = UIColor.color(data: categoryColorData!)
                let colorGradient = ColorGradient(Color(categoryUIColor!))
                total += totalTransactionAmountForCategory
                return ChartModel(category: category, amount: totalTransactionAmountForCategory, color: colorGradient, transactions: transactionByCategory, groupingType: groupingType, periodString: periodString)
            }
        }
        
        data = data.sorted { (first, second) -> Bool in
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
    var groupingType: ReportGroupingType
    var oppositeTotalAmount: Double
    var calculateNetBalance: Bool
    @Binding var refreshFlag: UUID
    
    var body: some View {
        VStack {
            let averages = getOverallAverageAndPerDayAndTotal()
            let averageDailyTransaction = averages.3
            let averagesDailyTransactionAmount = averages.1
            if reportType == .expense {
                let averageTransaction = averages.2
                let averageTransactionAmount = averages.0
                ExpenseSummaryView(averageTransactionCount: averageTransaction, averageTransactionAmount: averageTransactionAmount, transactionDays: averageDailyTransaction, dailyTransactionAmount: averagesDailyTransactionAmount, amountColor: amountColor, reportType: reportType)
            }
            else if calculateNetBalance {
                let currency = chartData.first?.transactions.first?.amount?.currencyValue.currency ?? ""
                let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
                let oppositeAmount = oppositeTotalAmount
                let netAmount = totalAmount - oppositeAmount
                IncomeSummaryView(netAmount: netAmount, oppositeAmount: oppositeAmount, currencySign: currencySign, amountColor: amountColor, transactionDays: averageDailyTransaction, averageTransactionAmount: averagesDailyTransactionAmount)
            }
            LazyVStack {
                ForEach(chartData, id: \.self) {
                    chartModel in
                    if let firstData = chartData.first {
                        if chartModel.groupingType == .categories {
                            CategoryReportCellView(chartModel: chartModel, firstData: firstData, totalAmount: totalAmount, amountColor: amountColor, refreshFlag: $refreshFlag)
                        }
                        else {
                            PaymentMethodReportCellView(chartModel: chartModel, firstData: firstData, totalAmount: totalAmount, amountColor: amountColor, refreshFlag: $refreshFlag)
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
                if elapsedDayOfThisPeriodAndCheckIsSamePeriodAndTotalDaysOfSelectedPeriod!.1 && reportType == .expense {
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

struct IncomeSummaryView: View {
    var netAmount: Double
    var oppositeAmount: Double
    var currencySign: String
    var amountColor: Color
    var transactionDays: Int
    var averageTransactionAmount: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: .small) {
            VStack(alignment: .leading) {
                Text("Total")
                    .font(.footnote)
                    .hidden()
                Text("Substract with")
                    .font(.footnote)
                    .padding(.bottom)
                Text("Total")
                    .font(.footnote)
                    .hidden()
                Text("Divided by")
                    .font(.footnote)
            }
            VStack(alignment: .leading) {
                Text("Total Expense")
                    .font(.footnote)
                Text(CurrencyHelper.string(from: oppositeAmount, currency: currencySign))
                    .foregroundColor(Color(UIColor.systemRed))
                    .font(.footnote).bold()
                    .padding(.bottom)
                Text("Total Transactions")
                    .font(.footnote)
                Text("\(transactionDays) day(s)")
                    .font(.footnote).bold()
            }
            Divider()
            VStack(alignment: .leading) {
                Text("Net Income")
                    .font(.footnote)
                Text(CurrencyHelper.string(from: netAmount, currency: currencySign))
                    .foregroundColor(amountColor)
                    .font(.footnote).bold()
                    .padding(.bottom)
                Text("Daily Income")
                    .font(.footnote)
                Text(averageTransactionAmount)
                    .foregroundColor(amountColor)
                    .font(.footnote).bold()
            }
            Spacer()
        }.padding()
    }
}

struct ExpenseSummaryView: View {
    let averageTransactionCount: Int
    let averageTransactionAmount: String
    let transactionDays: Int
    let dailyTransactionAmount: String
    let amountColor: Color
    let reportType: CategoryType
    
    var body: some View {
        HStack(alignment: .bottom, spacing: .medium) {
            VStack(alignment: .leading, spacing: .tiny) {
                Text("")
                    .font(.footnote)
                Text("Divided by")
                    .font(.footnote)
                Text("Average")
                    .font(.footnote)
            }
            if averageTransactionCount > 0 {
                VStack(alignment: .leading, spacing: .tiny) {
                    Text("Overall \(reportType.rawValue)")
                        .font(.footnote)
                    Text("\(averageTransactionCount) transaction(s)")
                        .font(.footnote)
                    Text(averageTransactionAmount)
                        .font(.footnote).bold()
                        .foregroundColor(amountColor)
                }
            }
            if transactionDays > 0 {
                VStack(alignment: .leading, spacing: .tiny) {
                    Text("Daily \(reportType.rawValue)")
                        .font(.footnote)
                    Text("\(transactionDays) day(s)")
                        .font(.footnote)
                    Text(dailyTransactionAmount)
                        .font(.footnote).bold()
                        .foregroundColor(amountColor)
                }
            }
            Spacer()
        }.padding()
    }
}

struct CategoryReportCellView: View {
    
    var chartModel: ChartModel
    var firstData: ChartModel
    var totalAmount: Double
    var amountColor: Color
    @Binding var refreshFlag: UUID
    var paymentMethodName: String?
    
    var body: some View {
        if let category = chartModel.category {
            let largestAmount = firstData.amount
            let color = chartModel.color.startColor
            let amount = chartModel.amount
            let percentage = amount / totalAmount * 100
            let decimals = percentage.truncatingRemainder(dividingBy: 1.0) == 0 ? 0 : 2
            let percentageFormat = String(format: "%.\(decimals)f", percentage)
            let percentageToShow = percentage < 1 ? "< 0" : percentageFormat
            let transaction = firstData.transactions.first
            let currency = transaction?.amount?.currencyValue.currency ?? ""
            let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
            NavigationLink(
                destination: ReportCategoryGroupingDetailView(refreshFlag: $refreshFlag, chartModel: chartModel, paymentMethodName: paymentMethodName),
                label: {
                    VStack {
                        HStack(alignment: .top) {
                            CategoryIconDisplayView(category: category, iconWidth: 50.0, iconHeight: 50.0)
                                .padding()
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Spacer()
                                    Text(category.name ?? "")
                                        .font(.footnote)
                                        .foregroundColor(Color(UIColor.label))
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
                                    .foregroundColor(Color(UIColor.label))
                            }
                        }
                        Divider()
                    }
                }
            )
        }
    }
}

struct PaymentMethodReportCellView: View {
    
    var chartModel: ChartModel
    var firstData: ChartModel
    var totalAmount: Double
    var amountColor: Color
    @Binding var refreshFlag: UUID
    
    var body: some View {
        if let paymentMethod = chartModel.paymentMethod {
            let largestAmount = firstData.amount
            let color = chartModel.color.startColor
            let amount = chartModel.amount
            let percentage = amount / totalAmount * 100
            let decimals = percentage.truncatingRemainder(dividingBy: 1.0) == 0 ? 0 : 2
            let percentageFormat = String(format: "%.\(decimals)f", percentage)
            let percentageToShow = percentage < 1 ? "< 0" : percentageFormat
            let transaction = firstData.transactions.first
            let currency = transaction?.amount?.currencyValue.currency ?? ""
            let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
            let cardWidth:CGFloat = 105.0
            let cardHeight:CGFloat = 56.0
            NavigationLink(
                destination: ReportPaymentMethodGroupingDetailView(refreshFlag: $refreshFlag, chartModel: chartModel, reportType: CategoryType(rawValue: transaction?.category?.type ?? "") ?? .expense),
                label: {
                    VStack {
                        HStack(alignment: .top) {
                            PaymentMethodCardView(paymentMethod: paymentMethod, selectedPaymentMethod: .constant(nil), showLabel: false)
                                .frame(width: cardWidth, height: cardHeight)
                                .padding()
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Spacer()
                                    Text(paymentMethod.name ?? "")
                                        .foregroundColor(Color(UIColor.label))
                                        .font(.footnote)
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
                                    .foregroundColor(Color(UIColor.label))
                            }
                        }
                        Divider()
                    }
                }
            )
        }
    }
}

