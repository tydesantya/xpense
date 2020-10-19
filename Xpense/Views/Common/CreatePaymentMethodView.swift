//
//  CreatePaymentMethodView.swift
//  Xpense
//
//  Created by Teddy Santya on 11/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SPAlert

struct CreatePaymentMethodView: View {
    
    @Binding var showSheetView: Bool
    @State var amount: Double = 0
    @State var currency: CurrencyValue
    @State var currencySign: String!
    @State var numOfDecimalPoint: Int = 0
    @State var decimalSeparator: String = ","
    @State var groupingSeparator: String = "."
    @State var currencyText: String!
    var paymentMethodType: PaymentMethodType
    var numberFormatter: NumberFormatter!
    
    var body: some View {
        NavigationView {
            GeometryReader {
                reader in
                ScrollView {
                    VStack(alignment: .center) {
                        ZStack(alignment: .center) {
                            PaymentMethodCard(backgroundColor: paymentMethodColor())
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
                                        Text(CurrencyHelper.string(from: amount, currency: self.currencySign))
                                            .bold()
                                            .foregroundColor(.white)
                                        Text("Total cash")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Text(self.currencySign)
                                        .font(.hugeTitle)
                                        .foregroundColor(.white)
                                        .opacity(0.5)
                                }
                            }.padding()
                        }.frame(width: reader.size.width - 100, height: 150)
                        .padding()
                        VStack {
                            Text("Enter amount")
                                .font(.footnote)
                                .foregroundColor(.init(.secondaryLabel))
                            CurrencyTextField(amount: self.$amount, currency: self.$currency)
                                .background(Color.init(.secondarySystemBackground)
                                                .cornerRadius(.normal))
                        }.padding(.horizontal)
                        Text("Number Formatting")
                            .font(.footnote)
                            .foregroundColor(.init(.secondaryLabel))
                            .padding(.top)
                        VStack {
                            HStack {
                                Text("Currency")
                                Spacer()
                                Text(self.currencyText)
                            }.padding(.horizontal)
                            Divider().padding(.horizontal)
                            HStack {
                                Text("Grouping Separator")
                                Spacer()
                                Text(groupingSeparator)
                            }.padding(.horizontal)
                            Divider().padding(.horizontal)
                            HStack {
                                Text("Decimal Points")
                                Spacer()
                                Text("\(numOfDecimalPoint)")
                            }.padding(.horizontal)
                            Divider().padding(.horizontal)
                            HStack {
                                Text("Decimal Separator")
                                Spacer()
                                Text(decimalSeparator)
                            }.padding(.horizontal)
                        }
                        .foregroundColor(.init(.quaternaryLabel))
                        .padding(.vertical)
                        .background(Color.init(.secondarySystemBackground)
                                        .cornerRadius(.normal))
                        .opacity(0.7)
                        HStack {
                            Spacer()
                            Text("Customization is currently not supported")
                                .font(.caption)
                                .foregroundColor(.init(.tertiaryLabel))
                        }
                    }
                    .padding()
                }.gesture(
                    TapGesture()
                        .onEnded { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
            }.navigationBarTitle(Text(getNavigationTitle()), displayMode: .inline)
            .navigationBarItems(leading: getLeadingNavigationItem(), trailing: getTrailingNavigationItem())
        }
    }
    
    
    init(paymentMethodType: PaymentMethodType, showSheetView: Binding<Bool>) {
        self.paymentMethodType = paymentMethodType
        self._showSheetView = showSheetView
        let defaultCurrency = "IDR"
        _currencyText = .init(initialValue: defaultCurrency)
        _currency = .init(initialValue: CurrencyValue(amount: "0", currency: defaultCurrency))
        _currencySign = .init(initialValue: CurrencyHelper.getCurrencySignFromCurrency(defaultCurrency))
        self.numberFormatter = CurrencyHelper.getNumberFormatterFor(currencyText, 0)
    }
    
    func getLeadingNavigationItem() -> AnyView {
        switch paymentMethodType {
        case .cash:
            return AnyView(EmptyView())
        default:
            return AnyView(EmptyView())
        }
    }
    
    func getTrailingNavigationItem() -> AnyView {
        switch paymentMethodType {
        case .cash:
            return AnyView(
                Button(action: {
                    self.createCashAndDismiss()
                }) {
                    Text("Done").bold()
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
    
    func getNavigationTitle() -> String {
        switch paymentMethodType {
        case .cash:
            return "Cash"
        default:
            return ""
        }
    }
    
    func paymentMethodColor() -> Color {
        switch paymentMethodType {
        case .cash:
            return self.cashColor()
        default:
            return self.cashColor()
        }
    }
    
    func cashColor() -> Color {
        return Color.init(UIColor.systemGreen.darker()!)
    }
    
    func createCashAndDismiss() {
        let amountString = numOfDecimalPoint == 0 ? String(format: "%.0f", amount) : String(amount)
        let currency = CurrencyValue(amount: amountString, currency: self.currencyText)
        let displayCurrencyValue = DisplayCurrencyValue(currencyValue: currency, numOfDecimalPoint: self.numOfDecimalPoint, decimalSeparator: self.decimalSeparator, groupingSeparator: self.groupingSeparator)
        let cash = CoreDataManager.shared.createPaymentMethod(balance: displayCurrencyValue, type: .cash, identifierNumber: "", name: "Cash", color: UIColor(cashColor()))
        if let _ = cash {
            self.showSheetView = false
            SPAlert.present(title: "Added to Wallet", preset: .done)
        }
    }
}

struct CreatePaymentMethodView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePaymentMethodView(paymentMethodType: .cash, showSheetView: Binding<Bool>(get: { () -> Bool in
            return true
        }, set: { (flag) in
            
        }))
    }
}


