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
                    .padding()
                    Divider()
                    ScrollView {
                        LazyVStack {
                            HStack {
                                Text("Transactions")
                                    .font(.subheadline)
                                    .bold()
                                Spacer()
                            }
                            ForEach(0..<50) { index in
                                TransactionCellView(category: Category(name: "Shopping", icon: UIImage(systemName: "bag.fill")!, color: .purple), navigationDestination: navigateToView(_:))
                            }
                        }
                        .padding()
                        .background(Color.init(.systemBackground))
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
    
    init(paymentMethodType: PaymentMethodType) {
        _paymentMethodType = .init(initialValue: paymentMethodType)
        fetchRequest = FetchRequest<PaymentMethod>(entity: PaymentMethod.entity(), sortDescriptors: [], predicate: NSPredicate(format: "type == %ld", paymentMethodType.rawValue))
        _selectedPaymentMethod = .init(initialValue: nil)
        _editedPaymentMethod = .init(initialValue: nil)
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
    
    func getTitle() -> String {
        switch paymentMethodType {
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
}

struct CreditCardListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardListDetailView(paymentMethodType: .debitCard)
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
