//
//  BudgetDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 2/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import PartialSheet
import SwiftUICharts

struct BudgetDetailView: View {
    
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    @State var refreshFlag = UUID()
    @State var startDate = Date()
    @State var endDate = Date()
    @State var hasSetupEndDate = false
    var budgetPeriod: BudgetPeriod
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = budgetPeriod == .daily ? "dd MMM yyyy" : "MMMM yyyy"
        return formatter
    }
    
    var dateRangeFormatter: DateIntervalFormatter {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var navigationTitle: String {
        budgetPeriod == .weekly ? dateRangeFormatter.string(from: startDate, to: endDate) : dateFormatter.string(from: startDate)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                BudgetDetailContentView(fetchRequest: makeSelectedDateBudgetFetchRequest(), refreshFlag: $refreshFlag, periodString: .init(get: { () -> String in
                    return navigationTitle
                }, set: { (new) in
                    // do nothing
                }))
            }
            .frame(maxWidth: .infinity)
        }.navigationTitle(navigationTitle)
        .navigationBarItems(trailing: HStack {
            Button(action: {
                self.partialSheetManager.showPartialSheet({
                        print("Partial sheet dismissed")
                    }) {
                    BudgetDatePickerView(dateSelection: $startDate, endingDateSelection: $endDate, type: budgetPeriod)
                }
            }) {
                Image(systemSymbol: .calendar)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.2)
                    .padding()
            }
        })
        .onAppear {
            if !hasSetupEndDate {
                switch budgetPeriod {
                case .daily:
                    startDate = startDate.startOfDay
                    endDate = startDate.endOfDay
                case .weekly:
                    startDate = startDate.startOfWeek()
                    endDate = startDate.endOfWeek
                case .monthly:
                    startDate = startDate.startOfMonth()
                    endDate = startDate.endOfMonth
                }
                hasSetupEndDate = true
            }
        }
    }
    
    func makeSelectedDateBudgetFetchRequest() -> FetchRequest<PeriodicBudget> {
        let predicate = NSPredicate(format: "startDate <= %@ && endDate >= %@", startDate as NSDate, endDate as NSDate)
        return FetchRequest<PeriodicBudget>(entity: PeriodicBudget.entity(), sortDescriptors: [], predicate: predicate, animation: .spring())
    }
}

struct BudgetDetailContentView: View {
    
    @State var budgetsProgress:[Float] = [1.0, 1.0, 1.0]
    var fetchRequest: FetchRequest<PeriodicBudget>
    private var data: FetchedResults<PeriodicBudget> {
        fetchRequest.wrappedValue
    }
    @Binding var refreshFlag: UUID
    @Binding var periodString: String
    
    var body: some View {
        VStack {
            if let periodBudget = data.first {
                if let budgets = periodBudget.budgets {
                    let budgetsArray = budgets.allObjects as! [Budget]
                    let sortedBudgetsArray = budgetsArray.sorted { (first, second) -> Bool in
                        return first.order < second.order
                    }
                    BudgetRingView(periodicBudget: periodBudget, largestSize: 200.0, lineWidth: 25).padding(.vertical)
                    ForEach(sortedBudgetsArray, id:\.self) {
                        budget in
                        let category = budget.category!
                        let categoryColorData = category.color!
                        let categoryUiColor = UIColor.color(data: categoryColorData)!
                        let size: CGFloat = 30
                        let used = budget.usedAmount
                        let usedAmount = used!.toDouble()
                        let limit = budget.limit
                        let limitAmount = limit!.toDouble()
                        let transactions =  budget.transactions!.allObjects as! [TransactionModel]
                        let chartModel = ChartModel(category: category, paymentMethod: nil, amount: usedAmount, color: ColorGradient(Color(.clear)), transactions: transactions, groupingType: .categories, periodString: periodString)
                        NavigationLink(
                            destination: ReportCategoryGroupingDetailView(refreshFlag: $refreshFlag, chartModel: chartModel),
                            label: {
                                VStack {
                                    HStack {
                                        Text(category.name ?? "")
                                            .foregroundColor(Color(UIColor.label))
                                        Spacer()
                                    }
                                    .padding([.horizontal, .top])
                                    .padding(.bottom, .tiny)
                                    HStack {
                                    CategoryIconDisplayView(category: category, iconWidth: size, iconHeight: size)
                                        .padding()
                                    VStack(alignment: .leading, spacing: 0) {
                                        Spacer()
                                        Text("Spent")
                                            .font(.footnote)
                                            .foregroundColor(Color(UIColor.label))
                                        HStack(alignment: .bottom, spacing: 0) {
                                            Text(used!.toString())
                                                .font(.header)
                                                .foregroundColor(Color(categoryUiColor))
                                            Spacer()
                                        }
                                        HStack {
                                            ProgressView(value: usedAmount > limitAmount ? limitAmount : usedAmount, total: limitAmount)
                                                .accentColor(Color(categoryUiColor))
                                            Text(limit!.toString()).font(.footnote)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                                .frame(minWidth: 100, alignment: .trailing)
                                                .padding(.trailing)
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                    Image(systemSymbol: .chevronRight)
                                        .padding(.trailing)
                                        .foregroundColor(Color(UIColor.label))
                                }
                                    .background(Color(UIColor.secondarySystemBackground))
                                }
                            }
                            )
                    }
                }
            }
            else {
                VStack(spacing: .small) {
                    Text("No Data")
                        .bold()
                    Text("Your Budget Detail Will Appear Here for Past Date only")
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }.frame(minHeight: 200)
            }
        }
        .id(refreshFlag)
    }
}

struct BudgetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetDetailView(budgetPeriod: .weekly)
    }
}
