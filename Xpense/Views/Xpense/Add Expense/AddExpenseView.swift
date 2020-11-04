//
//  AddExpenseView.swift
//  Xpense
//
//  Created by Teddy Santya on 27/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SFSafeSymbols
import SPAlert

struct AddExpenseView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [])
    private var paymentMethods: FetchedResults<PaymentMethod>
    
    @Binding var showSheetView: Bool
    @Binding var refreshFlag: UUID
    @State var amount: Double = 0
    @State var currency: CurrencyValue
    @State var notes: String = ""
    @State var selectedPaymentMethod: PaymentMethod? = nil
    @State var showValidationAlert = false
    var amountTemplates: [Double] {
        [
            10000,
            20000,
            50000,
            100000
        ]
    }
    
    @State var transactionTypes: [String] = []
    @State var transactionTypeSelectedIndex: Int = 0
    
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "type == %ld", PaymentMethodType.eWallet.rawValue))
    private var eWallets: FetchedResults<PaymentMethod>
    @State var topUpWithFee: Bool = true
    @State var selectedCategory: CategoryModel? = nil
    @State var categorySelectNavigation = false
    @State var selectedTopUpMethod: PaymentMethod?
    
    var selectedTransaction: TransactionModel?
    @State var populatedTransactionDetail = false
    
    @FetchRequest(
        entity: PeriodicBudget.entity(),
        sortDescriptors: [
        ],
        predicate: NSPredicate(format: "startDate <= %@ && endDate >= %@", Date() as NSDate, Date() as NSDate)
    ) var periodicBudgets: FetchedResults<PeriodicBudget>
    var isSelectingTopUp: Bool {
        eWallets.count > 0 && transactionTypeSelectedIndex == 0
    }
    
    init(showSheetView:Binding<Bool>, refreshFlag:Binding<UUID>, selectedTransaction: TransactionModel? = nil) {
        self._showSheetView = showSheetView
        _refreshFlag = refreshFlag
        let defaultCurrency = "IDR"
        _currency = .init(initialValue: CurrencyValue(amount: "0", currency: defaultCurrency))
        self.selectedTransaction = selectedTransaction
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center) {
                    Picker(selection: $transactionTypeSelectedIndex, label: Text("")) {
                        ForEach(0..<transactionTypes.count) {
                            index in
                            Text(transactionTypes[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .id(transactionTypes.count)
                    .padding()
                    if isSelectingTopUp {
                        EWalletSelectionView(eWallets: eWallets, topUpSelection: $selectedTopUpMethod, topUpWithFee: $topUpWithFee)
                    }
                    else {
                        let categoryType = CategoryType(rawValue: transactionTypes[transactionTypeSelectedIndex])
                        CategorySelectionView(selectedCategory: $selectedCategory, onCategoriesViewSelectedCategory: onCategoriesViewSelectedCategory(_:), categorySelectNavigation: $categorySelectNavigation, fetchRequest: makeCategoriesFetchRequest(), type: categoryType)
                    }
                    VStack {
                        Text("Enter amount")
                            .font(.footnote)
                            .foregroundColor(.init(.secondaryLabel))
                        CurrencyTextField(amount: self.$amount, currency: self.$currency)
                            .background(Color.init(.secondarySystemBackground)
                                            .cornerRadius(.normal))
                    }.padding(.horizontal)
                    HStack {
                        ForEach(amountTemplates, id:\.self) { amnt in
                            Button(action: {
                                self.amount = amnt
                            }) {
                                VStack {
                                    Image(systemName: "cylinder.split.1x2.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .padding(.top)
                                        .padding(.bottom, .tiny)
                                    Text(CurrencyHelper.string(from: amnt, currency: CurrencyHelper.getCurrencySignFromCurrency(self.currency.currency)!))
                                        .padding(.bottom)
                                }.foregroundColor(Color(UIColor.label))
                                .frame(minWidth: 50, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                                .background(Color.init(.secondarySystemBackground))
                                .cornerRadius(.normal)
                                .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)
                    Text("Select Payment Method")
                        .font(.footnote)
                        .foregroundColor(.init(.secondaryLabel))
                        .padding(.top)
                    ScrollView (.horizontal, showsIndicators: false) {
                        let width = CGFloat(150)
                        let height = CGFloat(80)
                        LazyHStack {
                            ForEach(getPaymentMethods()) { paymentMethod in
                                PaymentMethodCardView(paymentMethod: paymentMethod, selectedPaymentMethod: $selectedPaymentMethod)
                                    .frame(width: width, height: height)
                            }
                        }
                        .padding(.horizontal)
                    }
                    ZStack {
                        Color.init(.secondarySystemBackground)
                            .cornerRadius(.normal)
                        ZStack(alignment: .topLeading) {
                            let labelText = notes.count > 0 ? notes : "Notes"
                            let textColor = notes.count > 0 ? Color.init(.label) : Color.init(.tertiaryLabel)
                            Text(labelText)
                                .padding([.leading, .trailing], 5)
                                .padding([.top, .bottom], 8)
                                .foregroundColor(textColor)
                            TextEditor(text: self.$notes)
                        }
                        .padding(.small)
                    }
                    .padding()
                    .frame(minHeight: 200)
                }
            }.navigationBarTitle(Text("Add Transaction"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.showSheetView = false
            }) {
                Text("Cancel").bold()
            }, trailing: Button(action: {
                if amount == 0 {
                    showValidationAlert.toggle()
                }
                else if let transaction = selectedTransaction {
                    editTransaction(transaction)
                }
                else {
                    createTransaction()
                }
            }) {
                let title = selectedTransaction != nil ? "Done" : "Add"
                Text(title).bold()
            })
            .onAppear {
                if selectedPaymentMethod == nil {
                    selectedPaymentMethod = paymentMethods.first
                }
                if let transaction = selectedTransaction {
                    if !populatedTransactionDetail {
                        populatedTransactionDetail = true
                        populateSelectedTransactionDetail(transaction)
                    }
                }
                
                if transactionTypes.count == 0 {
                    if eWallets.count > 0 {
                        transactionTypes.append("Top Up")
                        transactionTypeSelectedIndex = 1
                    }
                    else {
                        transactionTypeSelectedIndex = 0
                    }
                    transactionTypes.append(contentsOf: CategoryType.allCases.map{$0.rawValue})
                    
                }
            }
        }.alert(isPresented: $showValidationAlert) {
            Alert(title: Text("Error"), message: Text("Please enter transaction amount!"), dismissButton: .default(Text("Got it")))
        }
        .accentColor(.theme)
    }
    
    func onCategoriesViewSelectedCategory(_ category: CategoryModel) {
        category.lastUsed = Date()
        selectedCategory = category
        do {
            try viewContext.save()
            categorySelectNavigation.toggle()
        } catch let createError {
            print("Failed to edit Category \(createError)")
        }
    }
    
    func populateSelectedTransactionDetail(_ transaction: TransactionModel) {
        if let category = transaction.category {
            category.lastUsed = Date()
            selectedCategory = category
            do {
                try viewContext.save()
            } catch let createError {
                print("Failed to edit Category \(createError)")
            }
        }
        if let paymentMethod = transaction.paymentMethod {
            selectedPaymentMethod = paymentMethod
        }
        if let note = transaction.note {
            notes = note
        }
        if let amount = transaction.amount?.currencyValue.amount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.amount = Double(amount) ?? 0
            }
        }
    }
    
    func editTransaction(_ transaction: TransactionModel) {
        revertTransactionPaymentMethodAmount(transaction)
        transaction.amount = getDisplayCurrencyValueFromAmount(amt: amount)
        transaction.note = notes
        transaction.category = selectedCategory
        transaction.paymentMethod = selectedPaymentMethod
        selectedCategory!.lastUsed = Date()
        
        deductSelectedPaymentMethodWithCurrentAmount()
        do {
            try viewContext.save()
            refreshFlag = UUID()
            SPAlert.present(title: "Edited Transaction", preset: .done)
            self.showSheetView = false
        } catch let createError {
            print("Failed to edit Category \(createError)")
        }
    }
    
    func createTransaction() {
        if isSelectingTopUp {
            createTopUpTransaction()
        }
        else {
            createCategoryTransaction()
        }
    }
    
    func createCategoryTransaction() {
        let transaction = TransactionModel(context: viewContext)
        transaction.amount = getDisplayCurrencyValueFromAmount(amt: amount)
        transaction.note = notes
        transaction.category = selectedCategory
        transaction.paymentMethod = selectedPaymentMethod
        transaction.date = Date()
        selectedCategory!.lastUsed = Date()
        
        deductSelectedPaymentMethodWithCurrentAmount()
        
        if let periodicBudget = periodicBudgets.first {
            let budgets = periodicBudget.budgets!.allObjects as! [Budget]
            for budget in budgets {
                if budget.category! == selectedCategory {
                    let initialBudgetUsedAmount = budget.usedAmount!.toDouble()
                    let newBudgetAmount = initialBudgetUsedAmount + amount
                    budget.usedAmount = getDisplayCurrencyValueFromAmount(amt: newBudgetAmount)
                    transaction.budget = budget
                }
            }
        }
        do {
            try viewContext.save()
            refreshFlag = UUID()
            SPAlert.present(title: "Added Transaction", preset: .done)
            self.showSheetView = false
        } catch let createError {
            print("Failed to edit Category \(createError)")
        }
    }
    
    func createTopUpTransaction() {
        // create top up model
        let topup = TopUp(context: viewContext)
        
        
        // create transaction from source payment method
        let transactionDate = Date()
        
        let transaction = TransactionModel(context: viewContext)
        transaction.amount = getDisplayCurrencyValueFromAmount(amt: amount)
        transaction.note = notes
        transaction.paymentMethod = selectedPaymentMethod
        transaction.date = transactionDate
        
        deductSelectedPaymentMethodWithCurrentAmount()
        
        
        let topUpTargetTransaction = TransactionModel(context: viewContext)
        topUpTargetTransaction.amount = getDisplayCurrencyValueFromAmount(amt: amount)
        topUpTargetTransaction.note = notes
        topUpTargetTransaction.paymentMethod = selectedTopUpMethod
        topUpTargetTransaction.date = transactionDate
        
        increaseTopUpTargetBalanceWithCurrentAmount()
        
        topup.topUpSource = transaction
        topup.topUpTarget = topUpTargetTransaction
        
        do {
            try viewContext.save()
            refreshFlag = UUID()
            SPAlert.present(title: "Added Transaction", preset: .done)
            self.showSheetView = false
        } catch let createError {
            print("Failed to edit Category \(createError)")
        }
    }
    
    func deductSelectedPaymentMethodWithCurrentAmount() {
        let initialAmountString: String = selectedPaymentMethod?.balance?.currencyValue.amount ?? ""
        let initialAmount = Double(initialAmountString) ?? 0
        let categoryType = CategoryType(rawValue: selectedCategory?.type ?? "") ?? .expense
        let deductedCurrentAmount = categoryType == .expense || isSelectingTopUp ? initialAmount - amount : initialAmount + amount
        
        let balance = getDisplayCurrencyValueFromAmount(amt: deductedCurrentAmount)
        selectedPaymentMethod?.balance = balance
    }
    
    func increaseTopUpTargetBalanceWithCurrentAmount() {
        let initialAmountString: String = selectedTopUpMethod?.balance?.currencyValue.amount ?? ""
        let initialAmount = Double(initialAmountString) ?? 0
        let increasedAmount = initialAmount + amount
        
        let balance = getDisplayCurrencyValueFromAmount(amt: increasedAmount)
        selectedTopUpMethod?.balance = balance
    }
    
    func revertTransactionPaymentMethodAmount(_ transaction: TransactionModel) {
        let amountString = transaction.amount?.currencyValue.amount ?? ""
        let amount = Double(amountString) ?? 0
        let initialAmountString: String = transaction.amount?.currencyValue.amount ?? ""
        let initialAmount = Double(initialAmountString) ?? 0
        let categoryType = CategoryType(rawValue: transaction.category?.type ?? "") ?? .expense
        let revertedAmount = categoryType == .expense ? initialAmount + amount : initialAmount - amount
        
        let balance = getDisplayCurrencyValueFromAmount(amt: revertedAmount)
        transaction.paymentMethod?.balance = balance
    }
    
    func getDisplayCurrencyValueFromAmount(amt: Double) -> DisplayCurrencyValue {
        let numOfDecimalPoint = selectedPaymentMethod?.balance?.numOfDecimalPoint
        let decimalSeparator = selectedPaymentMethod?.balance?.decimalSeparator
        let groupingSeparator = selectedPaymentMethod?.balance?.groupingSeparator
        let amountString = numOfDecimalPoint == 0 ? String(format: "%.0f", amt) : String(amt)
        let currency = CurrencyValue(amount: amountString, currency: selectedPaymentMethod?.balance?.currencyValue.currency ?? "")
        return DisplayCurrencyValue(currencyValue: currency, numOfDecimalPoint: numOfDecimalPoint ?? 0, decimalSeparator: decimalSeparator ?? ",", groupingSeparator: groupingSeparator ?? ".")
    }
    
    func makeCategoriesFetchRequest() -> FetchRequest<CategoryModel> {
        let type = transactionTypes[transactionTypeSelectedIndex]
        let predicate = NSPredicate(format: "type == %@", type)
        let sort = NSSortDescriptor(key: "lastUsed", ascending: false)
        return FetchRequest<CategoryModel>(entity: CategoryModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func getPaymentMethods() -> [PaymentMethod] {
        return paymentMethods.filter { (method) -> Bool in
            let isEWalletActive = isSelectingTopUp
            let isEWallet = method.type == PaymentMethodType.eWallet.rawValue
            let shouldInclude = isEWallet && isEWalletActive
            return !shouldInclude
        }
    }
    
}

struct PaymentMethodCardView: View {
    
    var paymentMethod: PaymentMethod
    @Binding var selectedPaymentMethod: PaymentMethod?
    var showLabel: Bool = true
    
    var body: some View {
        Button(action: {
            selectedPaymentMethod = paymentMethod
        }) {
            ZStack {
                PaymentMethodCard(backgroundColor: Color.init(UIColor.color(data: paymentMethod.color!)!), shadow: 0.0)
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            PlaceHolderView()
                                .frame(width: 75, height: 5)
                            PlaceHolderView()
                                .frame(width: 50, height: 5)
                            PlaceHolderView()
                                .frame(width: 25, height: 5)
                        }
                        Spacer()
                        if selectedPaymentMethod == paymentMethod {
                            Image(systemSymbol: .checkmarkSealFill)
                                .foregroundColor(.white)
                        }
                    }
                    if showLabel {
                        HStack {
                            Spacer()
                            Text(paymentMethod.name ?? "")
                                .font(.callout)
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                }.padding(.horizontal, .normal)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.theme, lineWidth: selectedPaymentMethod == paymentMethod ? 2 : 0)
            )
        }
    }
}

struct CategorySelectionView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedCategory: CategoryModel?
    var onCategoriesViewSelectedCategory: (CategoryModel) -> Void
    @Binding var categorySelectNavigation: Bool
    
    var fetchRequest: FetchRequest<CategoryModel>
    var categories: FetchedResults<CategoryModel> {
        fetchRequest.wrappedValue
    }
    var type: CategoryType?
    
    var body: some View {
        ZStack {
            if let selectedCategory = selectedCategory {
                let selectedCategoryColor = Color(UIColor.color(data: selectedCategory.color!)!)
                let selectedCategoryLighterColor = Color(UIColor.color(data: selectedCategory.lighterColor!)!)
                Circle()
                    .fill(
                        LinearGradient(gradient: .init(colors: [selectedCategoryLighterColor, selectedCategoryColor]), startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 100, height: 100)
                if let text = selectedCategory.text {
                    Text(text)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                else {
                    let symbolSelection:SFSymbol = SFSymbol(rawValue: selectedCategory.symbolName ?? "") ?? .archiveboxFill
                    Image(systemSymbol: symbolSelection)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                    .foregroundColor(.white)
                }
            }
        }
        Text(selectedCategory?.name ?? "")
            .bold()
            .padding(.top, .small)
        HStack(alignment: .top) {
            Spacer()
            ForEach(0 ..< (categories.count > 5 ? 4 : categories.count)) { i in
                let category = categories[i]
                if category != selectedCategory {
                    let customTextIcon = category.text
                    let symbolSelection:SFSymbol = SFSymbol(rawValue: category.symbolName ?? "") ?? .archiveboxFill
                    Button(action: {
                        selectedCategory = category
                    }) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(gradient: .init(colors: [Color(UIColor.color(data: category.lighterColor!)!), Color(UIColor.color(data: category.color!)!)]), startPoint: .top, endPoint: .bottom)
                                    )
                                    .frame(width: 50, height: 50)
                                if let text = customTextIcon {
                                    Text(text)
                                        .font(.system(size: 25, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                else {
                                    Image(systemSymbol: symbolSelection)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                    .foregroundColor(.white)
                                }
                            }.padding(.top, .large)
                            Text(category.name ?? "")
                                .bold()
                                .font(.caption)
                                .padding(.top, .tiny)
                                .padding(.bottom, .medium)
                                .frame(width: 50)
                                .foregroundColor(Color(UIColor.label))
                        }
                    }
                    Spacer()
                }
            }
            NavigationLink(
                destination: CategoriesView(selectionAction: onCategoriesViewSelectedCategory, specificType: type)
                    .environment(\.managedObjectContext, self.viewContext),
                isActive: self.$categorySelectNavigation,
                label: {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(
                                    Color.blue.opacity(0.5)
                                )
                                .frame(width: 50, height: 50)
                            Image(systemSymbol: .ellipsis)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.blue)
                        }.padding(.top, .large)
                        Text("More")
                            .bold()
                            .font(.caption)
                            .padding(.top, .tiny)
                            .padding(.bottom, .medium)
                            .foregroundColor(Color(UIColor.label))
                    }
                })
            Spacer()
        }.onAppear {
            if selectedCategory == nil || selectedCategory?.type != type?.rawValue {
                selectedCategory = categories.first
            }
        }
        .onChange(of: categories.count, perform: { value in
            selectedCategory = categories.first
        })
    }
}

struct EWalletSelectionView: View {
    
    var eWallets: FetchedResults<PaymentMethod>
    @Binding var topUpSelection: PaymentMethod?
    @Binding var topUpWithFee: Bool
    
    var body: some View {
        VStack {
            Text("Select E-Wallet to Top Up")
                .font(.footnote)
                .foregroundColor(.init(.secondaryLabel))
            ScrollView (.horizontal, showsIndicators: false) {
                let width = CGFloat(150)
                let height = CGFloat(80)
                LazyHStack {
                    ForEach(eWallets) { paymentMethod in
                        PaymentMethodCardView(paymentMethod: paymentMethod, selectedPaymentMethod: $topUpSelection)
                            .frame(width: width, height: height)
                    }
                }
                .padding(.horizontal)
            }.frame(height: 80)
            Toggle(isOn: $topUpWithFee, label: {
                Text("Top Up with Fee")
            })
            .padding()
            .background(Color.init(.secondarySystemBackground)
                            .cornerRadius(.normal))
            .padding([.horizontal, .bottom])
        }
        .padding(.bottom)
        .onAppear {
            topUpSelection = eWallets.first
        }
        .onChange(of: eWallets.count, perform: { value in
            topUpSelection = eWallets.first
        })
    }
    
}

struct AddExpenseView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddExpenseView(showSheetView: Binding<Bool>(get: {
            return true
        }, set: { (flag) in
            
        }), refreshFlag: .init(get: { () -> UUID in
            return UUID()
        }, set: { (uuid) in
            
        }))
        .environment(\.colorScheme, .dark)
    }
}
