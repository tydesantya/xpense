//
//  CategoriesGrid.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SFSafeSymbols
import SPAlert
import Firebase

struct CategoriesGrid: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<CategoryModel>
    private var data: FetchedResults<CategoryModel> {
        fetchRequest.wrappedValue
    }
    var categoryTapAction:(CategoryModel) -> Void
    @State var showDeleteConfirmation = false
    @State var longPressedCategory: CategoryModel? = nil
    @State var categorySelectNavigation = false
    @Binding var refreshFlag: UUID
    
    var flexibleLayout = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: flexibleLayout, spacing: .small) {
                ForEach(data) { category in
                    CategoryItem(category: category)
                        .onTapGesture {
                            categoryTapAction(category)
                        }
                        .contextMenu {
                            Button(action: {
                                longPressedCategory = category
                                showDeleteConfirmation.toggle()
                            }) {
                                Label {
                                    Text("Delete").foregroundColor(.red)
                                } icon: {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }.foregroundColor(.red)
                            }
                        }
                        .actionSheet(isPresented: $showDeleteConfirmation, content: {
                            let budgetExists = longPressedCategory!.budgets!.count > 0
                            if longPressedCategory?.transactions?.count ?? 0 > 0 {
                                let transactionsCount = longPressedCategory!.transactions!.count
                                let budgetText = budgetExists ? "and budget setup " : ""
                                return ActionSheet(title: Text("Delete Confirmation"), message: Text("There are \(transactionsCount) transactions \(budgetText)in this category, do you want to merge it to another category or delete all of it ?"), buttons: [
                                    .default(Text("Merge to another category")) {
                                        categorySelectNavigation = true
                                    },
                                    .destructive(Text("Delete")) {
                                        revertCategoryAmount()
                                        deleteCategory(longPressedCategory!)
                                    },
                                    .cancel()
                                ])
                            }
                            else if budgetExists {
                                return ActionSheet(title: Text("Delete Confirmation"), message: Text("There are budget setup in this category, do you want to merge it to another category or delete from budget"), buttons: [
                                    .default(Text("Merge to another category")) {
                                        categorySelectNavigation = true
                                    },
                                    .destructive(Text("Delete")) {
                                        revertCategoryAmount()
                                        deleteCategoryAlongWithBudget(longPressedCategory!)
                                    },
                                    .cancel()
                                ])
                            }
                            return ActionSheet(title: Text("Delete Confirmation"), message: Text("Are you sure you want to delete this category ?"), buttons: [
                                .destructive(Text("Delete")) {
                                    deleteCategory(longPressedCategory!)
                                },
                                .cancel()
                            ])
                        })
                }
                NavigationLink(
                    destination: CategoriesView(selectionAction: onSelectCategoryToMigrate, migrationSelection: longPressedCategory)
                        .environment(\.managedObjectContext, self.viewContext),
                    isActive: self.$categorySelectNavigation,
                    label: {
                        EmptyView()
                    }
                )
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    func onSelectCategoryToMigrate(_ category: CategoryModel) {
        Analytics.logEvent("migrate_category", parameters: [
            "fromCategory": longPressedCategory?.name ?? "",
            "toCategory": category.name ?? ""
        ])
        let budgetExists = longPressedCategory!.budgets!.count > 0
        categorySelectNavigation = false
        if let transactions = longPressedCategory!.transactions {
            let transactionGroup = groupTransactionByPaymentMethod(transactions.allObjects as! [TransactionModel])
            for key in Array(transactionGroup.keys) {
                for transaction in transactionGroup[key]! {
                    transaction.category = category
                }
            }
        }
        if budgetExists {
            let budgets = longPressedCategory!.budgets!.allObjects as! [Budget]
            let currentBudgetExist = category.budgets!.count > 0
            if !currentBudgetExist {
                for budget in budgets {
                    budget.category = category
                }
            }
        }
        deleteCategory(longPressedCategory!)
    }
    
    private func groupTransactionByPaymentMethod(_ transactions : [TransactionModel])-> [PaymentMethod:[TransactionModel]] {
        return Dictionary(grouping: transactions){ (transaction : TransactionModel) -> PaymentMethod in
            return transaction.paymentMethod!
        }
    }
    
    func revertPaymentMethodAmount(_ paymentMethod: PaymentMethod, amount: Double) {
        let initialAmountString: String = paymentMethod.balance?.currencyValue.amount ?? ""
        let initialAmount = Double(initialAmountString) ?? 0
        let categoryType = CategoryType(rawValue: longPressedCategory!.type ?? "") ?? .expense
        let revertedAmount = categoryType == .expense ? initialAmount + amount : initialAmount - amount
        
        let balance = getDisplayCurrencyValueFromAmount(amt: revertedAmount, selectedPaymentMethod: paymentMethod)
        paymentMethod.balance = balance
    }
    
    func getDisplayCurrencyValueFromAmount(amt: Double, selectedPaymentMethod: PaymentMethod?) -> DisplayCurrencyValue {
        let numOfDecimalPoint = selectedPaymentMethod?.balance?.numOfDecimalPoint
        let decimalSeparator = selectedPaymentMethod?.balance?.decimalSeparator
        let groupingSeparator = selectedPaymentMethod?.balance?.groupingSeparator
        let amountString = numOfDecimalPoint == 0 ? String(format: "%.0f", amt) : String(amt)
        let currency = CurrencyValue(amount: amountString, currency: selectedPaymentMethod?.balance?.currencyValue.currency ?? "")
        return DisplayCurrencyValue(currencyValue: currency, numOfDecimalPoint: numOfDecimalPoint ?? 0, decimalSeparator: decimalSeparator ?? ",", groupingSeparator: groupingSeparator ?? ".")
    }
    
    func deleteCategory(_ category: CategoryModel) {
        Analytics.logEvent("delete_category", parameters: [
            "categoryName": category.name ?? ""
        ])
        do {
            viewContext.delete(category)
            try viewContext.save()
            SPAlert.present(title: "Deleted Category", preset: .done)
            refreshFlag = UUID()
            NotificationCenter.default.post(name: NSNotification.Name("CategoryUpdated"), object: nil)
        } catch let createError {
            print("Failed to delete Category \(createError)")
        }
    }
    
    func deleteCategoryAlongWithBudget(_ category: CategoryModel) {
        Analytics.logEvent("delete_category_with_budget", parameters: [
            "categoryName": category.name ?? ""
        ])
        do {
            let budgets = category.budgets!.allObjects as! [Budget]
            for budget in budgets {
                viewContext.delete(budget)
            }
            viewContext.delete(category)
            try viewContext.save()
            SPAlert.present(title: "Deleted Category", preset: .done)
            refreshFlag = UUID()
            NotificationCenter.default.post(name: NSNotification.Name("CategoryUpdated"), object: nil)
        } catch let createError {
            print("Failed to delete Category \(createError)")
        }
    }
    
    func revertCategoryAmount() {
        if let transactions = longPressedCategory!.transactions {
            let transactionGroup = groupTransactionByPaymentMethod(transactions.allObjects as! [TransactionModel])
            for key in Array(transactionGroup.keys) {
                var paymentMethodRevertAmount: Double = 0
                for transaction in transactionGroup[key]! {
                    let transactionAmountString = transaction.amount?.currencyValue.amount ?? ""
                    let transactionAmount = Double(transactionAmountString) ?? 0
                    paymentMethodRevertAmount += transactionAmount
                    viewContext.delete(transaction)
                }
                revertPaymentMethodAmount(key, amount: paymentMethodRevertAmount)
            }
        }
    }

}

struct CategoryItem: View {
    
    var category: CategoryModel
    var customTextIcon: String? {
        category.text
    }
    var categoryLighterColor: Color {
        Color(UIColor.color(data: category.color!)!.lighter(by: 10.0)!)
    }
    var categoryColor: Color {
        Color(UIColor.color(data: category.color!)!)
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
            }
            ZStack {
                Circle().fill(Color.init(UIColor.color(data: category.color!)!))
                    .frame(width: 40, height: 40)
                if let text = customTextIcon {
                    Text(text)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                else {
                    if let symbolName = category.symbolName {
                        Image(systemSymbol: SFSymbol(rawValue: symbolName) ?? .bagFill)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                }
            }
            Text(category.name ?? "")
                .bold()
                .foregroundColor(.white)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
        .background(
            LinearGradient(gradient: Gradient(colors: [categoryLighterColor, categoryColor]), startPoint: .center, endPoint: .trailing)
        )
        .cornerRadius(.normal)
    }
}
