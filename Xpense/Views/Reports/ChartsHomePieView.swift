//
//  ChartsHomePieView.swift
//  Xpense
//
//  Created by Teddy Santya on 28/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SwiftUICharts
import CoreData
import SFSafeSymbols

struct ChartsHomePieView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var selectedMonth = 10
    @State var selectedYear = 2020
    
    var body: some View {
        VStack {
            Text("October 2020")
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.secondarySystemBackground))
                    VStack {
                        Text("Income").font(.footnote).bold()
                            .padding(.top)
                        IncomePieChartView(fetchRequest: makeIncomeFetchRequest())
                        Spacer()
                    }
                }.padding()
                Divider()
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.secondarySystemBackground))
                    VStack {
                        Text("Expense").font(.footnote).bold()
                            .padding(.top)
                        IncomePieChartView(fetchRequest: makeExpenseFetchRequest())
                    }
                }.padding()
            }
        }
    }
    
    func mapFetchResultIntoChartDataAndStyle(_ result : FetchedResults<TransactionModel>)-> ([Double], ChartStyle) {
        var colors: [ColorGradient] = []
        let data = Dictionary(grouping: result){ (transaction : TransactionModel) -> CategoryModel in
            // group by category
            return transaction.category!
        }.values.map { (transactionByCategory) -> Double in
            var totalExpenseForCategory: Double = 0.0
            for transaction in transactionByCategory {
                let amountString: String = transaction.amount?.currencyValue.amount ?? "0"
                let amount: Double = Double(amountString)!
                totalExpenseForCategory += amount
            }
            let categoryColorData = transactionByCategory[0].category?.color
            let categoryUIColor = UIColor.color(data: categoryColorData!)
            let colorGradient = ColorGradient(Color(categoryUIColor!))
            colors.append(colorGradient)
            return totalExpenseForCategory
        }
        let chartStyle = ChartStyle(backgroundColor: Color(UIColor.systemBackground), foregroundColor: colors)
        return (data, chartStyle)
    }
    
    func makeIncomeFetchRequest() -> FetchRequest<TransactionModel> {
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        let startDateOfMonth = Calendar.current.date(from: components)
        
        components.year = 0
        components.month = 1
        components.day = -1
        let endDateOfMonth = Calendar.current.date(byAdding: components, to: startDateOfMonth!)
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let incomeType = CategoryType.income.rawValue
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@", startDateOfMonth! as NSDate , endDateOfMonth! as NSDate, incomeType)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func makeExpenseFetchRequest() -> FetchRequest<TransactionModel> {
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
    
    init() {
        let monthInt = Calendar.current.dateComponents([.month], from: Date()).month
        let yearInt = Calendar.current.dateComponents([.year], from: Date()).year
        
        self.selectedMonth = monthInt!
        self.selectedYear = yearInt!
    }
}

private struct IncomePieChartView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<TransactionModel>
    private var data: FetchedResults<TransactionModel> {
        fetchRequest.wrappedValue
    }
    
    var body: some View {
        let dataAndStyle = mapFetchResultIntoChartDataAndStyle(data)
        let listData = dataAndStyle.2
        VStack {
            PieChart()
            .data(dataAndStyle.0)
            .chartStyle(dataAndStyle.1)
            .padding()
            .aspectRatio(1, contentMode: .fit)
            VStack(alignment: .leading) {
                ForEach(listData.0) {
                    category in
                    let customTextIcon = category.text
                    let symbolSelection:SFSymbol = SFSymbol(rawValue: category.symbolName ?? "") ?? .archiveboxFill
                    let totalAmount = listData.1
                    let index = listData.0.firstIndex(of: category)
                    let categoryAmount = dataAndStyle.0[index!]
                    let percentage = categoryAmount / totalAmount * 100
                    let decimals = percentage.truncatingRemainder(dividingBy: 1.0) == 0 ? 0 : 2
                    let percentageFormat = String(format: "%.\(decimals)f", percentage)
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
                        Text("\(percentageFormat) %")
                        Spacer()
                    }
                }
            }.padding([.horizontal, .bottom])
        }
    }
    
    func mapFetchResultIntoChartDataAndStyle(_ result : FetchedResults<TransactionModel>)-> ([Double], ChartStyle, ([CategoryModel], Double)) {
        var total: Double = 0.0
        var colors: [ColorGradient] = []
        var categories: [CategoryModel] = []
        let data = Dictionary(grouping: result){ (transaction : TransactionModel) -> CategoryModel in
            // group by category
            return transaction.category!
        }.values.map { (transactionByCategory) -> (Double) in
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
            if categories.count < 3 {
                colors.append(colorGradient)
                categories.append(category)
            }
            total += totalExpenseForCategory
            return totalExpenseForCategory
        }
        
        let chartStyle = ChartStyle(backgroundColor: Color(UIColor.clear), foregroundColor: colors)
        return (data, chartStyle, (categories, total))
    }
    
}

struct ChartsHomePieView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsHomePieView()
    }
}
