//
//  ReportPaymentMethodGroupingDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 31/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SwiftUICharts
import Firebase

struct ReportPaymentMethodGroupingDetailView: View {
    
    @Binding var refreshFlag: UUID
    var chartModel: ChartModel
    var reportType: CategoryType
    var amountColor: Color {
        reportType == .expense ? Color(UIColor.systemRed) : Color(UIColor.systemGreen)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    if let paymentMethod = chartModel.paymentMethod {
                        let width: CGFloat = 150.0
                        let height: CGFloat = 80.0
                        PaymentMethodCardView(paymentMethod: paymentMethod, selectedPaymentMethod: .constant(nil))
                            .frame(width: width, height: height)
                        VStack(alignment: .leading) {
                            Text(paymentMethod.name!)
                                .font(.title)
                            let color = amountColor
                            let currency = chartModel.transactions.first?.amount?.currencyValue.currency ?? ""
                            let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
                            Text(CurrencyHelper.string(from: chartModel.amount, currency: currencySign))
                                .font(.sectionTitle)
                                .foregroundColor(color)
                        }
                        .padding(.leading, .medium)
                        Spacer()
                    }
                }.padding()
                Divider()
                HStack {
                    Text("Categories")
                        .font(.sectionTitle)
                    Spacer()
                }.padding([.leading, .top])
                LazyVStack {
                    let data = mapTransactionsIntoCategoryGroup(transactions: chartModel.transactions)
                    let models = data.0
                    ForEach(models, id: \.self) {
                        model in
                        CategoryReportCellView(chartModel: model, firstData: models.first!, totalAmount: data.1, amountColor: amountColor, refreshFlag: $refreshFlag, paymentMethodName: chartModel.paymentMethod?.name ?? "")
                    }
                }.background(
                    Color(UIColor.secondarySystemBackground)
                )
            }
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    "screenName": "Report Payment Method Grouping",
                    "paymentMethodName": chartModel.paymentMethod?.name ?? "",
                    "period": chartModel.periodString
                ])
            }
        }.navigationTitle(chartModel.periodString)
    }
    
    func mapTransactionsIntoCategoryGroup(transactions : [TransactionModel])-> ([ChartModel], Double) {
        var total: Double = 0.0
        var data: [ChartModel] = Dictionary(grouping: transactions){ (transaction : TransactionModel) -> CategoryModel in
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
            return ChartModel(category: category, amount: totalTransactionAmountForCategory, color: colorGradient, transactions: transactionByCategory, groupingType: .categories, periodString: chartModel.periodString)
        }
        
        data = data.sorted { (first, second) -> Bool in
            return first.amount > second.amount
        }
        return (data, total)
    }
    
}
