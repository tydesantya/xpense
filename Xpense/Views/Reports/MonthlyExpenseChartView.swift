//
//  MonthlyExpenseChartView.swift
//  Xpense
//
//  Created by Teddy Santya on 30/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct ChartModel: Hashable {
    var category: CategoryModel
    var amount: Double
    var color: ColorGradient
    var transactions: [TransactionModel]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
}

struct MonthlyExpenseChartView: View {
    @State var selectedMonth = 0
    @State var selectedYear = 0
    @State var segmentIndex = 0
    @State var selectedDate = Date()
    var segments = [
        "Day",
        "Month",
        "Year"
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Picker(selection: self.$segmentIndex, label: Text("")) {
                    ForEach(0..<self.segments.count) { index in
                        Text(self.segments[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: self.segmentIndex, perform: { value in
                    self.segmentChanged(value)
                })
                if selectedMonth > 0 && selectedYear > 0 {
                    ReportPieChartDetailView(fetchRequest: makeMonthlyExpenseFetchRequest(selectedMonth: selectedMonth, selectedYear: selectedYear))
                }
            }
        }.navigationTitle("Expense Report")
        .onAppear {
            setupCurrentMonth()
        }
    }
    
    func setupCurrentMonth() {
        let date = Date() // gets current date
        let calendar = Calendar.iso8601
        let currentYear = calendar.component(.year, from: date) // gets current year (i.e. 2020)
        let currentMonth = calendar.component(.month, from: date)
        self.selectedMonth = currentMonth
        self.selectedYear = currentYear
    }
    
    func makeMonthlyExpenseFetchRequest(selectedMonth: Int, selectedYear: Int) -> FetchRequest<TransactionModel> {
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        let startDateOfMonth = Calendar.current.date(from: components)
        
        components.year = 0
        components.month = 1
        components.day = -1
        let endDateOfMonth = Calendar.current.date(byAdding: components, to: startDateOfMonth!)
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let incomeType = CategoryType.expense.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@", startDateOfMonth! as NSDate , endDateOfMonth! as NSDate, incomeType)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func segmentChanged(_ segment: Int) {
        
    }
}

struct MonthlyExpenseChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyExpenseChartView()
    }
}

private struct ReportPieChartDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<TransactionModel>
    private var data: FetchedResults<TransactionModel> {
        fetchRequest.wrappedValue
    }
    
    var body: some View {
        let dataAndStyle = mapFetchResultIntoChartDataAndStyle(data)
        let listData = dataAndStyle.1
        VStack {
            PieChart()
                .data(listData.0.map{$0.amount})
                .chartStyle(dataAndStyle.0)
                .padding()
                .aspectRatio(CGSize(width: 1, height: 0.7), contentMode: .fit)
            ReportDetailListView(chartData: listData.0, totalAmount: listData.1).padding(.top)
        }
    }
    
    func mapFetchResultIntoChartDataAndStyle(_ result : FetchedResults<TransactionModel>)-> (ChartStyle, ([ChartModel], Double)) {
        var total: Double = 0.0
        let data = Dictionary(grouping: result){ (transaction : TransactionModel) -> CategoryModel in
            // group by category
            return transaction.category!
        }.values.map { (transactionByCategory) -> (ChartModel) in
            var totalExpenseForCategory: Double = 0.0
            for transaction in transactionByCategory {
                let amountString: String = transaction.amount?.currencyValue.amount ?? "0"
                let amount: Double = Double(amountString)!
                totalExpenseForCategory += amount
            }
            let category = transactionByCategory[0].category!
            let categoryColorData = category.color
            let categoryUIColor = UIColor.color(data: categoryColorData!)
            let colorGradient = ColorGradient(Color(categoryUIColor!))
            total += totalExpenseForCategory
            return ChartModel(category: category, amount: totalExpenseForCategory, color: colorGradient, transactions: transactionByCategory)
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
    
    var body: some View {
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
                                    HStack(alignment: .bottom) {
                                        Text(CurrencyHelper.string(from: amount, currency: currencySign))
                                            .font(.header)
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
