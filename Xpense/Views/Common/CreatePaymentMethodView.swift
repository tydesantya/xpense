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
    
    @Binding var showSheetView: WalletViewSheet?
    @Binding var sheetFlag: Bool
    @State var amount: Double = 0
    @State var currency: CurrencyValue
    @State var currencySign: String!
    @State var numOfDecimalPoint: Int = 0
    @State var decimalSeparator: String = ","
    @State var groupingSeparator: String = "."
    @State var currencyText: String!
    @State var cardColorSelection: Color
    @State var identifierNumber: String = ""
    @State var cardName: String = ""
    @State var isIdentifierValidated: Bool = false
    @State var validationAlertMessage: String = ""
    @State var showValidationAlert: Bool = false
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
                            paymentMethodForegroundView()
                        }.frame(width: abs(reader.size.width) - 100, height: 150)
                        .padding()
                        amountInputView()
                        paymentMethodSetupComponents()
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
                }
            }.navigationBarTitle(Text(getNavigationTitle()), displayMode: .inline)
            .navigationBarItems(leading: getLeadingNavigationItem(), trailing: getTrailingNavigationItem())
            .alert(isPresented: $showValidationAlert) {
                Alert(title: Text("Error"), message: Text(validationAlertMessage), dismissButton: .default(Text("Got it")))
            }
        }
    }
    
    
    init(paymentMethodType: PaymentMethodType, showSheetView: Binding<WalletViewSheet?>) {
        self.paymentMethodType = paymentMethodType
        self._showSheetView = showSheetView
        let defaultCurrency = "IDR"
        _sheetFlag = .init(get: { () -> Bool in
            return false
        }, set: { (flag) in
            
        })
        _currencyText = .init(initialValue: defaultCurrency)
        _currency = .init(initialValue: CurrencyValue(amount: "0", currency: defaultCurrency))
        _currencySign = .init(initialValue: CurrencyHelper.getCurrencySignFromCurrency(defaultCurrency))
        let initialColor = Color.init(UIColor.systemBlue.darker()!)
        _cardColorSelection = .init(initialValue: initialColor)
        self.numberFormatter = CurrencyHelper.getNumberFormatterFor(currencyText, 0)
    }
    
    init(paymentMethodType: PaymentMethodType, sheetFlag: Binding<Bool>) {
        self.paymentMethodType = paymentMethodType
        self._showSheetView = .init(get: { () -> WalletViewSheet? in
            return nil
        }, set: { (enu) in
        
        })
        let defaultCurrency = "IDR"
        _sheetFlag = sheetFlag
        _currencyText = .init(initialValue: defaultCurrency)
        _currency = .init(initialValue: CurrencyValue(amount: "0", currency: defaultCurrency))
        _currencySign = .init(initialValue: CurrencyHelper.getCurrencySignFromCurrency(defaultCurrency))
        let initialColor = Color.init(UIColor.systemBlue.darker()!)
        _cardColorSelection = .init(initialValue: initialColor)
        self.numberFormatter = CurrencyHelper.getNumberFormatterFor(currencyText, 0)
    }
    
    func paymentMethodForegroundView() -> AnyView {
        switch paymentMethodType {
        case .cash:
            return getCashForegroundView()
        case .creditCard:
            return getCardForegroundView()
        default:
            return AnyView(EmptyView())
        }
    }
    
    func getCardForegroundView() -> AnyView {
        AnyView(
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
                    Text(cardName.count > 0 ? cardName : "Card Name")
                        .bold()
                        .font(.title3)
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("XXXX XXXX XXXX \(identifierNumber.count > 0 ? identifierNumber : "XXXX")")
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
        )
    }
    
    func getCashForegroundView() -> AnyView {
        AnyView(
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
        )
    }
    
    func amountInputView() -> AnyView {
        switch paymentMethodType {
        case .cash:
            return getAmountInputView()
        case .creditCard:
            return AnyView(EmptyView())
        default:
            return getAmountInputView()
        }
    }
    
    func getAmountInputView() -> AnyView {
        AnyView(
            VStack {
                Text("Enter amount")
                    .font(.footnote)
                    .foregroundColor(.init(.secondaryLabel))
                CurrencyTextField(amount: self.$amount, currency: self.$currency)
                    .background(Color.init(.secondarySystemBackground)
                                    .cornerRadius(.normal))
            }.padding(.horizontal)
        )
    }
    
    func getLeadingNavigationItem() -> AnyView {
        switch paymentMethodType {
        case .cash:
            return AnyView(EmptyView())
        default:
            return AnyView(
                Button(action: {
                    self.cancel()
                }) {
                    Text("Cancel").bold()
                }
            )
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
        case .creditCard:
            return AnyView(
                Button(action: {
                    self.createCreditCardAndDismiss()
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
        case .creditCard:
            return "Credit Card"
        default:
            return ""
        }
    }
    
    func paymentMethodColor() -> Color {
        switch paymentMethodType {
        case .cash:
            return self.cashColor()
        default:
            return cardColorSelection
        }
    }
    
    func cashColor() -> Color {
        return Color.init(UIColor.systemGreen.darker()!)
    }
    
    func paymentMethodSetupComponents() -> AnyView {
        switch paymentMethodType {
        case .creditCard:
            return AnyView(CardSetupComponents(colorSelection: $cardColorSelection, identifier: $identifierNumber, isIdentifierValidated: $isIdentifierValidated, cardName: $cardName))
        default:
            return AnyView(EmptyView())
        }
    }
    
    func createCashAndDismiss() {
        if (amount > 0) {
            let amountString = numOfDecimalPoint == 0 ? String(format: "%.0f", amount) : String(amount)
            let currency = CurrencyValue(amount: amountString, currency: self.currencyText)
            let displayCurrencyValue = DisplayCurrencyValue(currencyValue: currency, numOfDecimalPoint: self.numOfDecimalPoint, decimalSeparator: self.decimalSeparator, groupingSeparator: self.groupingSeparator)
            let cash = CoreDataManager.shared.createPaymentMethod(balance: displayCurrencyValue, type: .cash, identifierNumber: "", name: "Cash", color: UIColor(cashColor()))
            if let _ = cash {
                self.showSheetView = nil
                self.sheetFlag = false
                SPAlert.present(title: "Added to Wallet", preset: .done)
            }
        }
        else {
            validationAlertMessage = "Please enter your current cash amount!"
            showValidationAlert = true
        }
    }
    
    func createCreditCardAndDismiss() {
        if (cardName.count == 0) {
            validationAlertMessage = "Please enter your card name!"
            showValidationAlert = true
            return
        }
        
        let ccIdentifier = isIdentifierValidated ? identifierNumber : "XXXX"
        let amountString = numOfDecimalPoint == 0 ? String(format: "%.0f", amount) : String(amount)
        let currency = CurrencyValue(amount: amountString, currency: self.currencyText)
        let displayCurrencyValue = DisplayCurrencyValue(currencyValue: currency, numOfDecimalPoint: self.numOfDecimalPoint, decimalSeparator: self.decimalSeparator, groupingSeparator: self.groupingSeparator)
        let cash = CoreDataManager.shared.createPaymentMethod(balance: displayCurrencyValue, type: .cash, identifierNumber: ccIdentifier, name: cardName, color: UIColor(cardColorSelection))
        if let _ = cash {
            self.showSheetView = nil
            self.sheetFlag = false
            SPAlert.present(title: "Added to Wallet", preset: .done)
        }
    }
    
    func cancel() {
        showSheetView = nil
        sheetFlag = false
    }
}

struct CreatePaymentMethodView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePaymentMethodView(paymentMethodType: .creditCard, showSheetView: Binding<WalletViewSheet?>(get: { () -> WalletViewSheet in
            return .addCreditCard
        }, set: { (flag) in
            
        }))
    }
}


private struct CardSetupComponents: View {
    
    @State var latestInputText: String = ""
    @Binding var colorSelection: Color
    @Binding var identifier: String
    @Binding var isIdentifierValidated: Bool
    @Binding var cardName: String
    
    var body: some View {
        VStack {
            Text("Card Styling")
                .font(.footnote)
                .foregroundColor(.init(.secondaryLabel))
                .padding(.top)
            VStack {
                HStack {
                    Text("Card Name")
                    TextField("BCA/Mandiri", text: $cardName)
                        .multilineTextAlignment(.trailing)
                        .introspectTextField(customize: UITextField.introspect())
                }
                Divider()
                HStack {
                    Text("Identifier Number")
                    TextField("XXXX", text: $identifier)
                        .introspectTextField(customize: UITextField.introspect())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: identifier, perform: { value in
                            if value.count > 4 {
                                identifier = latestInputText
                                return
                            }
                            isIdentifierValidated = value.count == 4
                            latestInputText = identifier
                        })
                }
                Divider()
                ColorPicker("Select Color", selection: $colorSelection)
            }.padding()
            .background(Color.init(.secondarySystemBackground)
                            .cornerRadius(.normal))
        }
        .onAppear {
            latestInputText = identifier
        }
    }
}
