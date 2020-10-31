//
//  CardListDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SPAlert

struct CardListDetailView: View {
    
    @State var paymentMethodType: PaymentMethodType
    @State var destinationView: AnyView?
    @State var navigate: Bool = false
    @State var showingAlert: Bool = false
    @State var createPaymentMethodFlag: Bool = false
    @State var pagerSelection: Int = 0
    @State var selectedPaymentMethod: PaymentMethod?
    @State var editedPaymentMethod: PaymentMethod?
    @Binding var presentedFlag: WalletViewSheet?
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<PaymentMethod>
    var paymentMethods : FetchedResults<PaymentMethod>{fetchRequest.wrappedValue}
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationLink(
                destination: destinationView,
                isActive: self.$navigate,
                label: {
                    EmptyView()
                })
            VStack(spacing: 0) {
                TrayIndicator()
                    .background(Color.init(.secondarySystemBackground))
                HStack {
                    VStack(alignment: .leading, spacing: .tiny) {
                        Text(getTitle())
                            .font(.sectionTitle)
                            .bold()
                        Text("Total Balance: \(getTotalWalletBalance())")
                    }
                    Spacer()
                    getAddCardButton()
                }
                .padding()
                .background(Color.init(.secondarySystemBackground))
                ViewPager(paymentMethodType: paymentMethodType, selection: $pagerSelection)
                    .environment(\.managedObjectContext, self.viewContext)
                    .frame(height: 220)
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: .tiny) {
                            Text(selectedPaymentMethod?.name ?? "empty")
                                .font(.subheadline)
                                .bold()
                            Text("Balance: \(getBalanceFromPaymentMethod(selectedPaymentMethod))")
                                .font(.footnote)
                        }
                        Spacer()
                        getCardActionView()
                    }
                    .padding()
                    Divider()
                    if let method = selectedPaymentMethod {
                        PaymentMethodTransactionsView(fetchRequest: makeTransactionsRequest(selectedPaymentMethod: method))
                    }
                }
                .background(Color.init(.secondarySystemBackground))
            }
            .edgesIgnoringSafeArea(.bottom)
            Button(action: {
                
            }) {
                HStack {
                    Image(systemSymbol: .sliderHorizontal3)
                        .font(.getFontFromDesign(design: .buttonTitle))
                    Text("Sort & Filter")
                        .font(.getFontFromDesign(design: .buttonTitle))
                }
                .padding(.vertical, .small)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.theme)
                        .shadow(radius: 5)
                )
                .foregroundColor(.white)
            }
        }
        .onChange(of: pagerSelection, perform: { value in
            if pagerSelection >= 0 && pagerSelection < paymentMethods.count {
                selectedPaymentMethod = paymentMethods[pagerSelection]
            }
            if paymentMethods.count <= 0 {
                presentedFlag = nil
            }
        })
        .navigationBarHidden(true)
        .sheet(isPresented: $createPaymentMethodFlag) {
            CreatePaymentMethodView(paymentMethodType: paymentMethodType, sheetFlag: $createPaymentMethodFlag, paymentMethod: editedPaymentMethod)
                .accentColor(.theme)
        }
        .alert(isPresented:$showingAlert) {
            Alert(title: Text("Warning"), message: Text("Are you sure you want to delete this card?"), primaryButton: .destructive(Text("Delete")) {
                pagerSelection -= 1
                deleteSelectedCard()
            }, secondaryButton: .cancel())
        }
    }
    
    func navigateToView(_ destination: AnyView?) {
        if let view = destination {
            destinationView = view
            self.navigate.toggle()
        }
    }
    
    init(paymentMethodType: PaymentMethodType, presentedFlag: Binding<WalletViewSheet?>) {
        _paymentMethodType = .init(initialValue: paymentMethodType)
        fetchRequest = FetchRequest<PaymentMethod>(entity: PaymentMethod.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %ld", paymentMethodType.rawValue))
        _selectedPaymentMethod = .init(initialValue: nil)
        _editedPaymentMethod = .init(initialValue: nil)
        _presentedFlag = presentedFlag
    }
    
    func getTotalWalletBalance() -> String {
        var totalBalance: Double = 0
        var currency = ""
        for method in paymentMethods {
            if let amt = method.balance?.currencyValue.amount {
                totalBalance += Double(amt) ?? 0
            }
            currency = method.balance?.currencyValue.currency ?? ""
        }
        let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
        return CurrencyHelper.string(from: totalBalance, currency: currencySign)
    }
    
    func getBalanceFromPaymentMethod(_ paymentMethod: PaymentMethod?) -> String {
        if let amt = paymentMethod?.balance?.currencyValue.amount, let currency = paymentMethod?.balance?.currencyValue.currency {
            let balance = Double(amt) ?? 0
            let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency) ?? ""
            return CurrencyHelper.string(from: balance, currency: currencySign)
        }
        return ""
    }
    
    func getAddCardButton() -> AnyView {
        switch paymentMethodType {
        case .creditCard, .debitCard:
            return AnyView(
                Button(action: {
                    let select = selectedPaymentMethod
                    let edit = editedPaymentMethod
                    
                    selectedPaymentMethod = nil
                    editedPaymentMethod = nil
                    
                    DispatchQueue.main.async {
                        editedPaymentMethod = edit
                        selectedPaymentMethod = select
                        
                        editedPaymentMethod = nil
                        createPaymentMethodFlag.toggle()
                    }
                }) {
                    Image(systemSymbol: .plusCircleFill)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.theme)
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
    
    func getCardActionView() -> AnyView {
        switch paymentMethodType {
        case .debitCard, .creditCard:
            return AnyView(
                HStack {
                    Button(action: {
                        let select = selectedPaymentMethod
                        let edit = editedPaymentMethod
                        
                        selectedPaymentMethod = nil
                        editedPaymentMethod = nil
                        
                        DispatchQueue.main.async {
                            editedPaymentMethod = edit
                            selectedPaymentMethod = select
                            
                            editedPaymentMethod = selectedPaymentMethod
                            createPaymentMethodFlag.toggle()
                        }
                    }) {
                        VStack {
                            Image(systemSymbol: .pencil)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.init(.label))
                            Text("Edit")
                                .font(.caption2)
                                .foregroundColor(Color.init(.label))
                        }
                    }.padding(.trailing)
                    Button(action: {
                        showingAlert.toggle()
                    }) {
                        VStack {
                            Image(systemSymbol: .trash)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color.init(.label))
                            Text("Delete")
                                .font(.caption2)
                                .foregroundColor(Color.init(.label))
                        }
                    }
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
    
    func getTitle() -> String {
        switch paymentMethodType {
        case .cash:
            return "Cash"
        case .creditCard:
            return "Credit Cards"
        case .debitCard:
            return "Debit Cards"
        default:
            return ""
        }
    }
    
    func deleteSelectedCard() {
        guard let paymentMethod = selectedPaymentMethod else { return }
        viewContext.delete(paymentMethod)
        do {
            try viewContext.save()
            SPAlert.present(title: "Card Deleted", preset: .done)
        } catch let createError {
            print("Failed to create PaymentMethod \(createError)")
        }
    }
    
    func makeTransactionsRequest(selectedPaymentMethod: PaymentMethod) -> FetchRequest<TransactionModel> {
        let predicate = NSPredicate(format: "paymentMethod == %@", selectedPaymentMethod)
        let sort = NSSortDescriptor(key: "date", ascending: false)
        return FetchRequest<TransactionModel>(entity: TransactionModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
}

struct CreditCardListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardListDetailView(paymentMethodType: .debitCard, presentedFlag: .init(get: { () -> WalletViewSheet in
            return .addCreditCard
        }, set: { (flag) in
            
        }))
    }
}

struct ViewPager: View {
    
    @Binding var selection:Int
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<PaymentMethod>
    var cards : FetchedResults<PaymentMethod>{fetchRequest.wrappedValue}
    
    var body: some View {
        TabView(selection: $selection){
            ForEach(cards, id: \.id) { card in
                ZStack {
                    PaymentMethodCard(backgroundColor: Color(getColorFromCard(card: card)))
                    VStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                PlaceHolderView()
                                    .frame(width: 150, height: 5)
                                PlaceHolderView()
                                    .frame(width: 100, height: 5)
                                PlaceHolderView()
                                    .frame(width: 50, height: 5)
                            }
                            Spacer()
                            Text(card.name ?? "")
                                .bold()
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        getCardBottomDesignFromCard(card: card)
                    }.padding()
                }
                .tabItem {
                    Text("test")
                }
                .tag(cards.firstIndex(of: card)!)
                .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fit)
                .padding(.top, 80)
                .offset(y: -50)
            }
        }
        .id(cards.count)
        .background(Color.init(.secondarySystemFill))
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .onAppear {
            // WORKAROUND: simulate change of selection on appear !!
            let value = selection
            selection = -1
            DispatchQueue.main.async {
                selection = value
            }
        }
    }
    
    func getCardBottomDesignFromCard(card: PaymentMethod) -> AnyView {
        let type = PaymentMethodType(rawValue: card.type)
        switch type {
        case .debitCard, .creditCard:
            return AnyView(
                VStack {
                    Spacer()
                    VStack(alignment: .center) {
                        Text("XXXX XXXX XXXX \(card.identifierNumber ?? "XXXX")")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    HStack {
                        Text("Teddy Santya")
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            )
        default:
            let currency = card.balance?.currencyValue.currency ?? ""
            let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency)
            return AnyView(
                HStack {
                    Spacer()
                    Text(currencySign ?? "")
                        .font(.hugeTitle)
                        .foregroundColor(.white)
                        .opacity(0.5)
                }
            )
        }
    }
    
    func getColorFromCard(card: PaymentMethod) -> UIColor {
        if let data = card.color {
            return UIColor.color(data: data)!
        }
        return UIColor.clear
    }
    
    init(paymentMethodType:PaymentMethodType, selection:Binding<Int>) {
        _selection = selection
        fetchRequest = FetchRequest<PaymentMethod>(entity: PaymentMethod.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %ld", paymentMethodType.rawValue))
    }
}


private struct PaymentMethodTransactionsView: View {
    
    var fetchRequest: FetchRequest<TransactionModel>
    private var data: FetchedResults<TransactionModel> {
        fetchRequest.wrappedValue
    }
    @State var refreshFlag: UUID = UUID()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                HStack {
                    Text("Transactions")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                }
                if (data.count > 0) {
                    ForEach(data) { trnsaction in
                        TransactionCellView(transaction: trnsaction, refreshFlag: $refreshFlag)
                    }
                }
                else {
                    VStack {
                        Text("No Transactions")
                    }.frame(minHeight: 200)
                }
            }.id(refreshFlag)
            .padding()
            .background(Color.init(.systemBackground))
        }
    }
    
}