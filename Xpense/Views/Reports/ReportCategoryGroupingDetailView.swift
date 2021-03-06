//
//  ReportCategoryGroupingDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 31/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import Firebase

struct ReportCategoryGroupingDetailView: View {
    
    @Binding var refreshFlag: UUID
    var chartModel: ChartModel
    var amountColor: Color {
        chartModel.category!.type == CategoryType.expense.rawValue ? Color(UIColor.systemRed) : Color(UIColor.systemGreen)
    }
    var paymentMethodName: String?
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    if let category = chartModel.category {
                        CategoryIconDisplayView(category: category, iconWidth: 100.0, iconHeight: 100.0)
                        VStack(alignment: .leading) {
                            Text(category.name!)
                                .font(.title)
                            let color = amountColor
                            let currency = chartModel.transactions.first?.amount?.currencyValue.currency ?? ""
                            let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
                            if chartModel.amount > 0 {
                                Text(CurrencyHelper.string(from: chartModel.amount, currency: currencySign))
                                    .font(.sectionTitle)
                                    .foregroundColor(color)
                            }
                            if let paymentMethodName = paymentMethodName {
                                let pillColorData = chartModel.transactions.first?.paymentMethod?.color!
                                let pillColor = Color(UIColor.color(data: pillColorData!)!)
                                Text(paymentMethodName)
                                    .font(.footnote)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.vertical, .tiny)
                                    .background(Capsule().fill(pillColor))
                            }
                        }
                        .padding(.leading, .medium)
                        Spacer()
                    }
                }
                .padding()
                Divider()
                VStack {
                    HStack {
                        Text("Transactions")
                            .font(.sectionTitle)
                        Spacer()
                    }
                    let data = chartModel.transactions.sorted { (first, second) -> Bool in
                        first.date! > second.date!
                    }
                    ForEach(data) { transaction in
                        TransactionCellView(transaction: transaction, refreshFlag: $refreshFlag, editable: false)
                    }
                    if data.count == 0 {
                        VStack {
                            Text("No Transactions For This Budget Period")
                        }.frame(minHeight: 200)
                    }
                }.padding()
            }.id(refreshFlag)
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    AnalyticsParameterScreenName: "Report Category Grouping",
                    "categoryName": chartModel.category?.name ?? "",
                    "paymentMethodName": paymentMethodName ?? "",
                    "period": chartModel.periodString
                ])
            }
        }.navigationTitle(chartModel.periodString)
        .padding(.top, 0.3)
    }
}
