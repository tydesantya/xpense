//
//  WalletView.swift
//  Xpense
//
//  Created by Teddy Santya on 7/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

enum WalletViewSheet: Int, Identifiable {
    case cashDetail
    case addCreditCard
    case addDebitCard
    case debitCardList
    case editCard
    var id: Int {
        hashValue
    }
}
struct WalletView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [])
    private var paymentMethods: FetchedResults<PaymentMethod>
    
    @State var showModally: Bool = true
    @State var activeSheet: WalletViewSheet?
    
    var body: some View {
        GeometryReader { reader in
            ScrollView {
                VStack {
                    HStack {
                        Text("Overview")
                            .font(.sectionTitle)
                        Spacer()
                    }.padding([.top, .horizontal])
                    VStack(alignment: .leading, spacing: .small) {
                        Text("Teddy Santya's Wallet")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.init(.secondaryLabel))
                        Divider()
                        Text(getTotalWalletBalance())
                            .font(.huge)
                        HStack {
                            Text("Total Balance")
                            Spacer()
                        }
                    }.padding()
                    .background(
                        Color.init(.secondarySystemBackground)
                            .cornerRadius(.medium)
                    )
                    .padding(.horizontal)
                    HStack {
                        Text("Payment Methods")
                            .font(.sectionTitle)
                        Spacer()
                    }.padding([.top, .horizontal])
                    VStack {
                        VStack {
                            CashWalletView(parentWidth: reader.size.width, cashTapAction: showCashDetail)
                            DebitCardWalletView(parentWidth: reader.size.width, addDebitAction: showAddDebitCard, debitDetailAction: showDebitCardList)
                            CreditCardWalletView(parentWidth: reader.size.width, showSheetAction: showAddCreditCard)
                            
                            HStack {
                                Text("E-Wallet")
                                    .font(Font.getFontFromDesign(design: .sectionTitle))
                                    .padding(.horizontal)
                                    .padding(.top, .medium)
                                Spacer()
                            }
                            .padding(.top, .normal)
                            AddCardPlaceholder(text: "Add E-Wallet")
                                .frame(width: abs(reader.size.width - 100), height: 150)
                                .padding(.bottom, .large)
                        }.padding(.horizontal)
                        .background(
                            Color.init(.secondarySystemBackground)
                                .cornerRadius(.medium)
                        )
                    }.padding([.horizontal, .bottom])
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .cashDetail:
                getCashCardSheet()
            case .debitCardList:
                getDebitCardSheet()
            case .addDebitCard:
                getAddDebitCardSheet()
            default:
                getAddCreditCardSheet()
            }
        }
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
    
    func getAddDebitCardSheet() -> AnyView {
        AnyView(
            CreatePaymentMethodView(paymentMethodType: .debitCard, showSheetView: self.$activeSheet)
                .presentation(isModal: self.$showModally) {
                    print("Attempted to dismiss")
                }
                .accentColor(.theme)
        )
    }
    
    func getAddCreditCardSheet() -> AnyView {
        AnyView(
            CreatePaymentMethodView(paymentMethodType: .creditCard, showSheetView: self.$activeSheet)
                .presentation(isModal: self.$showModally) {
                    print("Attempted to dismiss")
                }
                .accentColor(.theme)
        )
    }
    
    func getDebitCardSheet() -> AnyView {
        AnyView(
            NavigationView {
                CardListDetailView(paymentMethodType: .debitCard, presentedFlag: $activeSheet)
                    .environment(\.managedObjectContext, self.viewContext)
            }
        )
    }
    
    func getCashCardSheet() -> AnyView {
        AnyView(
            NavigationView {
                CardListDetailView(paymentMethodType: .cash, presentedFlag: $activeSheet)
                    .environment(\.managedObjectContext, self.viewContext)
            }
        )
    }
    
    func showAddCreditCard() {
        self.activeSheet = .addCreditCard
    }
    
    func showAddDebitCard() {
        self.activeSheet = .addDebitCard
    }
    
    func showDebitCardList() {
        self.activeSheet = .debitCardList
    }
    
    func showCashDetail() {
        self.activeSheet = .cashDetail
    }
}

struct PlaceHolderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 50)
            .fill(placeholderColor())
    }
    
    func placeholderColor() -> Color {
        let uiColor: UIColor = UIColor.gray.lighter()!
        return Color.init(uiColor)
    }
}

struct PaymentMethodCard: View {
    var backgroundColor: Color
    var shadow: CGFloat = 10.0
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .cornerRadius(10.0)
                .shadow(radius: 10.0)
            Rectangle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .padding()
                .opacity(0.0)
        }
    }
}

struct AddCardPlaceholder: View {
    
    var text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(
                    Color.blue.opacity(0.5)
                )
            RoundedRectangle(cornerRadius: 10.0)
                .strokeBorder(Color.blue)
            VStack {
                Image(systemSymbol: .plus)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.blue)
                    .padding()
                Text(text)
                    .bold()
                    .foregroundColor(.blue)
            }
        }
    }
}

struct DebitCardWalletView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "type == %ld", PaymentMethodType.debitCard.rawValue))
    private var debitCardPaymentMethod: FetchedResults<PaymentMethod>
    var parentWidth: CGFloat
    var addDebitAction: () -> Void
    var debitDetailAction: () -> Void
    
    var body: some View {
        let width = parentWidth > 0 ? parentWidth : 200
        if (debitCardPaymentMethod.count > 0) {
            VStack {
                HStack {
                    Text("Debit Cards")
                        .padding(.horizontal)
                        .padding(.top, .large)
                    Spacer()
                }
                ZStack {
                    ForEach(debitCardPaymentMethod) {
                        element in
                        getCardView(paymentMethod:element, width: width)
                    }
                }.onTapGesture {
                    debitDetailAction()
                }
            }
        }
        else {
            VStack {
                HStack {
                    Text("Debit Cards")
                        .padding(.horizontal)
                        .padding(.top, .medium)
                    Spacer()
                }
                .padding(.top)
                AddCardPlaceholder(text: "Add Debit Card")
                    .frame(width: abs(width - 100), height: 150)
                    .onTapGesture {
                        addDebitAction()
                    }
            }
        }
    }
    
    func getCardView(paymentMethod:PaymentMethod, width: CGFloat) -> AnyView {
        let index = debitCardPaymentMethod.firstIndex(of: paymentMethod)
        let offset = 10.0 * CGFloat(index!)
        let reverseIndex = debitCardPaymentMethod.count - 1 - index!
        let cardWidth = width - 100.0 - (20.0 * CGFloat(reverseIndex))
        return AnyView(
            ZStack {
                PaymentMethodCard(backgroundColor: Color(UIColor.color(data: paymentMethod.color!)!))
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
                        Text(paymentMethod.name ?? "")
                            .bold()
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .center) {
                        Text("XXXX XXXX XXXX \(paymentMethod.identifierNumber ?? "XXXX")")
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
            }.frame(width: abs(cardWidth), height: 160)
            .offset(y: offset)
        )
    }
    
}

struct CreditCardWalletView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "type == %ld", PaymentMethodType.creditCard.rawValue))
    private var ccPaymentMethod: FetchedResults<PaymentMethod>
    var parentWidth: CGFloat
    var showSheetAction: () -> Void
    
    var body: some View {
        let width = parentWidth > 0 ? parentWidth : 200
        if (ccPaymentMethod.count > 0) {
            
        }
        else {
            VStack {
                HStack {
                    Text("Credit Cards")
                        .padding(.horizontal)
                        .padding(.top, .small)
                    Spacer()
                }
                .padding(.top)
                AddCardPlaceholder(text: "Add Credit Card")
                    .frame(width: abs(width - 100), height: 150)
                    .onTapGesture {
                        showSheetAction()
                    }
            }
        }
    }
}

struct CashWalletView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "type == %ld", PaymentMethodType.cash.rawValue))
    private var cashPaymentMethod: FetchedResults<PaymentMethod>
    var parentWidth: CGFloat
    var cashTapAction: () -> Void
    
    var body: some View {
        if (cashPaymentMethod.count > 0) {
            let cashMethod = cashPaymentMethod.first
            let width = parentWidth > 0 ? parentWidth : 200
            let currency = cashMethod?.balance?.currencyValue.currency ?? ""
            let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency)
            VStack {
                HStack {
                    Text(cashMethod?.name ?? "")
                        .padding(.horizontal)
                        .padding(.top, .large)
                    Spacer()
                }
                ZStack {
                    PaymentMethodCard(backgroundColor: Color(UIColor.color(data: cashPaymentMethod[0].color!)!))
                    VStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                PlaceHolderView()
                                    .frame(width: 150, height: 5)
                                PlaceHolderView()
                                    .frame(width: 100, height: 5)
                                PlaceHolderView()
                                    .frame(width: 50, height: 5)
                                Spacer()
                            }
                            Spacer()
                        }.frame(height: 50)
                        HStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                Text(getTotalWalletBalance())
                                    .bold()
                                    .foregroundColor(.white)
                                Text("Total \(cashMethod?.name ?? "")")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Text(currencySign ?? "")
                                .font(.hugeTitle)
                                .foregroundColor(.white)
                                .opacity(0.5)
                        }
                    }.padding()
                }.frame(width: abs(width - 100), height: 150)
                .onTapGesture {
                    cashTapAction()
                }
            }
        }
        else {
            EmptyView()
        }
    }
    
    func getTotalWalletBalance() -> String {
        let cashMethod = cashPaymentMethod.first
        let amount: String = cashMethod?.balance?.currencyValue.amount ?? "0"
        let cashBalance = Double(amount) ?? 0
        
        let currency = cashMethod?.balance?.currencyValue.currency ?? ""
        let currencySign = CurrencyHelper.getCurrencySignFromCurrency(currency)
        return CurrencyHelper.string(from: cashBalance, currency: currencySign!)
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
