//
//  XpenseView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import CoreData

struct XpenseView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<TransactionModel>
    var transactions : FetchedResults<TransactionModel>{fetchRequest.wrappedValue}
    @State var progressValue: Float = 1.0
    @State var showAddBudget: Bool = false
    @Binding var refreshFlag: UUID
    var transactionLimit: Int {
        transactions.count > 3 ? 3 : transactions.count
    }
    
    @FetchRequest(
        entity: PeriodicBudget.entity(),
        sortDescriptors: [
        ],
        predicate: NSPredicate(format: "startDate <= %@ && endDate >= %@", Date() as NSDate, Date() as NSDate)
    ) var periodicBudgets: FetchedResults<PeriodicBudget>
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Daily Budget")
                        .font(Font.getFontFromDesign(design: .sectionTitle))
                        .padding([.top, .horizontal])
                        .onTapGesture {
                            showAddBudget.toggle()
                        }
                        .padding(.bottom, .small)
                    BudgetHomeView(periodicBudgets: periodicBudgets)
                    HStack {
                        Text("Transactions")
                            .font(Font.getFontFromDesign(design: .sectionTitle))
                        Spacer()
                        NavigationLink(destination: TransactionListView()) {
                            Text("See All")
                                .font(.getFontFromDesign(design: .buttonTitle))
                        }
                    }.padding(.horizontal)
                    .padding(.top, .small)
                    LazyVStack {
                        ForEach(0..<transactionLimit) { index in
                            if index < transactions.count {
                                let transaction = transactions[index]
                                TransactionCellView(transaction: transaction, refreshFlag: $refreshFlag)
                            }
                        }
                        if transactions.count == 0 {
                            VStack {
                                Text("No Data")
                            }.frame(minHeight: 200)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .id(refreshFlag)
        }.onAppear(perform: {
            withAnimation {
                self.progressValue = 0.5
            }
            refreshFlag = UUID()
        })
        .sheet(isPresented: $showAddBudget, content: {
            NavigationView {
                AddBudgetView(showSheetView: $showAddBudget)
                    .environment(\.managedObjectContext, self.viewContext)
            }.accentColor(.theme)
            .presentation(isModal: .constant(true)) {
                print("Attempted to dismiss")
            }
            .edgesIgnoringSafeArea(.bottom)
        })
    }
    
    init(uuid: Binding<UUID>) {
        _refreshFlag = uuid
        let request: NSFetchRequest<TransactionModel> = TransactionModel.fetchRequest()
        request.fetchLimit = 3
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest = FetchRequest<TransactionModel>(fetchRequest: request)
    }
}

struct BudgetHomeView: View {
    
    var periodicBudgets: FetchedResults<PeriodicBudget>
    @State var budgetsProgress:[Float] = [1.0, 1.0, 1.0]
    
    var body: some View {
        if let periodicBudget = periodicBudgets.first {
            if let budgets = periodicBudget.budgets {
                let budgetsArray = budgets.allObjects as! [Budget]
                let sortedBudgetsArray = budgetsArray.sorted { (first, second) -> Bool in
                    return first.order < second.order
                }
                HStack(alignment: .center) {
                    let initialSize:CGFloat = 120.0
                    ZStack {
                        ForEach(sortedBudgetsArray, id:\.self) {
                            budget in
                            let category = budget.category!
                            let categoryColorData = category.color!
                            let categoryUiColor = UIColor.color(data: categoryColorData)!
                            let index = sortedBudgetsArray.firstIndex(of: budget)
                            let size = initialSize - CGFloat((index! * 30))
                            ProgressBar(progress: $budgetsProgress[index!], color: categoryUiColor)
                                .frame(width: size, height: size)
                                .padding(.vertical)
                                .onAppear {
                                    withAnimation {
                                        let limit = budget.limit
                                        let limitAmount = limit!.toDouble()
                                        
                                        let used = budget.usedAmount
                                        let usedAmount = used!.toDouble()
                                        
                                        let progress = 1 - usedAmount / limitAmount
                                        budgetsProgress[index!] = Float(progress)
                                    }
                                }
                        }
                    }.padding(.leading, .normal)
                    .padding(.trailing, .tiny)
                    .padding(.vertical)
                    VStack(alignment: .leading) {
                        Spacer()
                        ForEach(sortedBudgetsArray, id: \.self) {
                            budget in
                            let category = budget.category!
                            let categoryColorData = category.color!
                            let categoryUiColor = UIColor.color(data: categoryColorData)!
                            let used = budget.usedAmount
                            let usedAmount = used!.toDouble()
                            let limit = budget.limit
                            let limitAmount = limit!.toDouble()
                            let leftAmount = limitAmount - usedAmount
                            let leftAmountDisplay = DisplayCurrencyValue(currencyValue: CurrencyValue(amount: String(leftAmount), currency: used!.currencyValue.currency), numOfDecimalPoint: used!.numOfDecimalPoint, decimalSeparator: used!.decimalSeparator, groupingSeparator: used!.groupingSeparator)
                            HStack(spacing: .small) {
                                CategoryIconDisplayView(category: category, iconWidth: 20.0, iconHeight: 20.0)
                                VStack(alignment: .leading) {
                                    HStack(spacing: 0) {
                                        Text("Budget: ")
                                        .font(.caption)
                                        Text(leftAmountDisplay.toString())
                                            .foregroundColor(Color(categoryUiColor))
                                            .bold()
                                            .font(.caption)
                                    }
                                    HStack(spacing: 0) {
                                        Text("Limit: ")
                                            .font(.caption)
                                        Text(limit!.toString())
                                            .font(.caption)
                                            .foregroundColor(Color(categoryUiColor))
                                    }
                                }
                            }
                            Spacer()
                        }
                    }.padding(.leading, .normal)
                    Spacer()
                }
                .padding(.horizontal, .small)
                .frame(maxWidth: .infinity)
                .background(Color.init(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
    }
}

struct XpenseView_Previews: PreviewProvider {
    static var previews: some View {
        XpenseView(uuid: .init(get: { () -> UUID in
            return UUID()
        }, set: { (uuid) in
            
        }))
    }
}
