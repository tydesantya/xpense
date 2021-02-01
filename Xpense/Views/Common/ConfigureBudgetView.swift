//
//  ConfigureBudgetView.swift
//  Xpense
//
//  Created by Teddy Santya on 31/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SPAlert
import Firebase

struct InputModel: Hashable {
    var category: CategoryModel
    var amount: Double
    var currencyValue: CurrencyValue
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
}

enum BudgetPeriod: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct ConfigureBudgetView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var inputModels: [InputModel]
    @State var progressValue: Float = 1.0
    @Binding var showSheetView: Bool
    @State var showErrorAlert: Bool = false
    @State var showConfirmationAlert: Bool = false
    var segments = BudgetPeriod.allCases
    @State var segmentIndex = 0
    var listId = 123
    
    var body: some View {
        ScrollView {
            ScrollViewReader {
                value in
                VStack {
                    Text("Budget Period")
                        .font(.footnote)
                        .padding(.top)
                    Picker(selection: self.$segmentIndex, label: Text("")) {
                        ForEach(0..<self.segments.count) { index in
                            Text(self.segments[index].rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.horizontal, .bottom])
                    let initialSize:CGFloat = 120.0
                    ZStack {
                        ForEach(inputModels, id: \.self) {
                            inputModel in
                            let category = inputModel.category
                            let index = inputModels.firstIndex(of: inputModel)!
                            if index < inputModels.count {
                                let size = initialSize - CGFloat((index * 30))
                                let categoryColorData = category.color
                                let categoryColor = UIColor.color(data: categoryColorData!)
                                ProgressBar(progress: self.$progressValue, color: categoryColor!)
                                    .frame(width: size, height: size)
                                    .padding(.vertical)
                            }
                        }
                    }
                    Text("Budget Ring Preview")
                        .font(.caption)
                    EmptyBudgetCreationView(showSheetView: $showSheetView, showConfirmationAlert: $showConfirmationAlert, segmentIndex: $segmentIndex, inputModels: $inputModels, fetchRequest: makeTransactionFetchRequest())
                    Text("Setup Budget Amount and Order")
                        .font(.sectionTitle)
                    List {
                        ForEach(0..<inputModels.count) {
                            index in
                            HStack {
                                let inputModel = inputModels[index]
                                let category = inputModel.category
                                let index = inputModels.firstIndex(of: inputModel)!
                                if index < inputModels.count {
                                    CategoryIconDisplayView(category: category, iconWidth: 80.0, iconHeight: 80.0)
                                        .padding()
                                    VStack {
                                        HStack {
                                            Text(category.name ?? "")
                                                .font(.footnote)
                                            Spacer()
                                        }
                                        TextEditor(text: /*@START_MENU_TOKEN@*/.constant("Placeholder")/*@END_MENU_TOKEN@*/)
                                        CurrencyTextField(amount: $inputModels[index].amount, currency: $inputModels[index].currencyValue, onFocus: {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation {
                                                    value.scrollTo(listId, anchor: .bottom)
                                                }
                                            }
                                        })
                                        .background(Color(UIColor.secondarySystemBackground).cornerRadius(.normal))
                                    }
                                }
                            }.frame(height: 100)
                        }
                        .onMove(perform: move)
                        .alert(isPresented: $showErrorAlert, content: {
                            Alert(title: Text("Error"), message: Text("Please enter all budget amount!"), dismissButton: .default(Text("Got it")))
                        })
                    }
                    .environment(\.defaultMinListRowHeight, 100)
                    .frame(height: 116.0 * CGFloat(inputModels.count))
                    .id(listId)
                }
                .onAppear {
                    Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                        AnalyticsParameterScreenName: "Configure Budget"
                    ])
                }
                .navigationTitle("Configure Budget")
                .navigationBarItems(trailing: Button(action: {
                    for inputModel in inputModels {
                        if inputModel.amount == 0 {
                            showErrorAlert = true
                            return
                        }
                    }
                    showConfirmationAlert = true
                }, label: {
                    Text("Done")
                        .bold()
                }))
            }
        }
    }
    
    func makeTransactionFetchRequest() -> FetchRequest<TransactionModel> {
        var startDate = Date()
        var endDate = Date()
        
        let period = self.segments[segmentIndex]
        switch period {
        case .daily:
            startDate = Date().startOfDay
            endDate = Date().endOfDay
        case .weekly:
            startDate = Date().startOfWeek()
            endDate = Date().endOfWeek
        case .monthly:
            startDate = Date().startOfMonth()
            endDate = Date().endOfMonth
        }
        
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ && category.type == %@ && category.shouldHide == 0", startDate as NSDate, endDate as NSDate, CategoryType.expense.rawValue)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [], predicate: predicate, animation: .spring())
    }
    
    func move(from source: IndexSet, to destination: Int) {
        inputModels.move(fromOffsets: source, toOffset: destination)
    }
    
    private func updateAmountOfInputModel(_ inputModel: InputModel, amount: Double) {
        let index = inputModels.firstIndex(of: inputModel)!
        inputModels[index].amount = amount
    }
    
    
    private func updateCurrencyValueOfInputModel(_ inputModel: InputModel, currencyValue: CurrencyValue) {
        let index = inputModels.firstIndex(of: inputModel)!
        inputModels[index].currencyValue = currencyValue
    }
}


struct EmptyBudgetCreationView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showSheetView: Bool
    @Binding var showConfirmationAlert: Bool
    @Binding var segmentIndex: Int
    @Binding var inputModels: [InputModel]
    var segments = BudgetPeriod.allCases
    var fetchRequest: FetchRequest<TransactionModel>
    private var data: FetchedResults<TransactionModel> {
        fetchRequest.wrappedValue
    }
    
    var body: some View {
        VStack {
            Divider()
                .padding()
        }
        .alert(isPresented: $showConfirmationAlert, content: {
            Alert(title: Text("Confirmation"), message: Text("Create this setup of budget ?\nYou will not be able to edit the budget unless you delete all entries of this budget"), primaryButton: .default(Text("Confirm")) {
                createBudget()
            }, secondaryButton: .cancel())
        })
    }
    
    func checkTransactions() {
        for transaction in data {
            print(transaction.amount!.toString())
        }
    }
    
    func groupDataIntoCategories() -> [CategoryModel: [TransactionModel]] {
        return Dictionary(grouping: data){ (transaction : TransactionModel) -> CategoryModel in
            // group by category
            return transaction.category!
        }
    }
    
    
    func createBudget() {
        let transactionGroup = groupDataIntoCategories()
        let periodicBudget = PeriodicBudget(context: viewContext)
        let period = self.segments[segmentIndex]
        periodicBudget.period = period.rawValue
        switch period {
        case .daily:
            periodicBudget.startDate = Date().startOfDay
            periodicBudget.endDate = Date().endOfDay
        case .weekly:
            periodicBudget.startDate = Date().startOfWeek()
            periodicBudget.endDate = Date().endOfWeek
        case .monthly:
            periodicBudget.startDate = Date().startOfMonth()
            periodicBudget.endDate = Date().endOfMonth
        }
        var index = 0
        for inputModel in inputModels {
            let budget = Budget(context: viewContext)
            budget.category = inputModel.category
            budget.limit = DisplayCurrencyValue(currencyValue: CurrencyValue(amount: String(inputModel.amount), currency: inputModel.currencyValue.currency), numOfDecimalPoint: 0, decimalSeparator: ",", groupingSeparator: ".")
            budget.periodicBudget = periodicBudget
            budget.order = Int64(index)
            
            var budgetUsedAmount: Double = 0.0
            let group = transactionGroup[inputModel.category]
            if let categoryGroup = group {
                for transaction in categoryGroup {
                    transaction.budget = budget
                    let amount = transaction.amount!.toDouble()
                    budgetUsedAmount += amount
                }
            }
            
            budget.usedAmount = DisplayCurrencyValue(currencyValue: CurrencyValue(amount: String(budgetUsedAmount), currency: inputModel.currencyValue.currency), numOfDecimalPoint: 0, decimalSeparator: ",", groupingSeparator: ".")
            index += 1
        }
        
        Analytics.logEvent("create_budget", parameters: [
            "period": period.rawValue,
            "categoryNames": inputModels.map{$0.category.name}
        ])
        do {
            try viewContext.save()
            SPAlert.present(title: "Budget Added", preset: .done)
            showSheetView = false
        } catch let createError {
            print("Failed to create budget \(createError)")
        }
    }
}
