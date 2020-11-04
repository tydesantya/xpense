//
//  CreatePaymentMethodView.swift
//  Xpense
//
//  Created by Teddy Santya on 11/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SPAlert
import UserNotifications

struct CreatePaymentMethodView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showSheetView: WalletViewSheet?
    @Binding var sheetFlag: Bool
    @State var amount: Double = 0
    @State var currency: CurrencyValue
    @State var topUpAmount: Double = 0
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
    @State var editingPaymentMethod: PaymentMethod?
    var paymentMethodType: PaymentMethodType
    var numberFormatter: NumberFormatter!
    
    @ObservedObject var settings = UserSettings()
    
    var body: some View {
        NavigationView {
            GeometryReader {
                reader in
                ScrollView {
                    VStack(alignment: .center) {
                        if paymentMethodType == .cash {
                            Text("Setup your cash balance to start using Xpense")
                                .font(.footnote)
                        }
                        ZStack(alignment: .center) {
                            PaymentMethodCard(backgroundColor: paymentMethodColor())
                            paymentMethodForegroundView()
                        }.frame(width: abs(reader.size.width - 100), height: 150)
                        .padding()
                        amountInputView()
                        if paymentMethodType == .eWallet {
                            getTopUpFeeView()
                        }
                        paymentMethodSetupComponents()
                        if paymentMethodType == .cash {
                            CurrencyFormattingView(numOfDecimalPoint: $numOfDecimalPoint, decimalSeparator: $decimalSeparator, groupingSeparator: $groupingSeparator, currencyText: $currencyText)
                        }
                        if paymentMethodType == .creditCard {
                            PaymentMethodReminderSetupView(monthlyReminderOn: $settings.creditCardReminderEnabled, monthlyReminderDate: $settings.creditCardNotificationDate)
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
    
    init(paymentMethodType: PaymentMethodType, sheetFlag: Binding<Bool>, paymentMethod: PaymentMethod? = nil) {
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
        if let paymentMethod = paymentMethod {
            _cardColorSelection = .init(initialValue: Color(UIColor.color(data: paymentMethod.color!)!))
            let initialAmount = Double(paymentMethod.balance?.currencyValue.amount ?? "0") ?? 0
            _amount = .init(initialValue: initialAmount)
            _cardName = .init(initialValue: paymentMethod.name ?? "asd")
            _identifierNumber = .init(initialValue: paymentMethod.identifierNumber ?? "")
            _editingPaymentMethod = .init(initialValue: paymentMethod)
        }
        else {
            let initialColor = Color.init(UIColor.systemBlue.darker()!)
            _cardColorSelection = .init(initialValue: initialColor)
        }
        self.numberFormatter = CurrencyHelper.getNumberFormatterFor(currencyText, 0)
    }
    
    func paymentMethodForegroundView() -> AnyView {
        switch paymentMethodType {
        case .cash:
            return getCashForegroundView()
        case .creditCard, .debitCard:
            return getCardForegroundView()
        default:
            return getEWalletForegroundView()
        }
    }
    
    func getEWalletForegroundView() -> AnyView {
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
                }
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(CurrencyHelper.string(from: amount, currency: self.currencySign))
                            .bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(cardName)
                        .font(.hugeTitle)
                        .foregroundColor(.white)
                        .opacity(0.5)
                }
            }.padding()
        )
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
                        .font(.subheadline)
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
        case .cash, .debitCard:
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
                Text("Enter Balance Amount")
                    .font(.footnote)
                    .foregroundColor(.init(.secondaryLabel))
                CurrencyTextField(amount: self.$amount, currency: self.$currency)
                    .background(Color.init(.secondarySystemBackground)
                                    .cornerRadius(.normal))
            }.padding(.horizontal)
        )
    }
    
    func getTopUpFeeView() -> AnyView {
        AnyView(
            VStack {
                Text("Top Up Fee")
                    .font(.footnote)
                    .foregroundColor(.init(.secondaryLabel))
                CurrencyTextField(amount: self.$topUpAmount, currency: self.$currency)
                    .background(Color.init(.secondarySystemBackground)
                                    .cornerRadius(.normal))
                HStack {
                    Spacer()
                    Text("Automatically deduct this amount everytime you top up")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.trailing)
                        .font(.caption)
                        .foregroundColor(.init(.tertiaryLabel))
                }
            }.padding()
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
        case .debitCard:
            return AnyView(
                Button(action: {
                    self.createDebitCardAndDismiss()
                }) {
                    Text("Done").bold()
                }
            )
        default:
            return AnyView(
                Button(action: {
                    self.createEWalletAndDismiss()
                }) {
                    Text("Done").bold()
                }
            )
        }
    }
    
    func getNavigationTitle() -> String {
        switch paymentMethodType {
        case .cash:
            return "Setup Wallet"
        case .creditCard:
            return "Credit Card"
        case .debitCard:
            return "Debit Card"
        default:
            return "E-Wallet"
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
        case .creditCard, .debitCard, .eWallet:
            return AnyView(CardSetupComponents(colorSelection: $cardColorSelection, identifier: $identifierNumber, isIdentifierValidated: $isIdentifierValidated, cardName: $cardName, type: paymentMethodType))
        default:
            return AnyView(EmptyView())
        }
    }
    
    func createCashAndDismiss() {
        if (amount > 0) {
            let displayCurrencyValue = getDisplayCurrencyValueFromCurrentAmount()
            let newPaymentMethod = editingPaymentMethod ?? PaymentMethod(context: viewContext)
            newPaymentMethod.name = "Cash"
            newPaymentMethod.balance = displayCurrencyValue
            newPaymentMethod.type = PaymentMethodType.cash.rawValue
            newPaymentMethod.identifierNumber = ""
            newPaymentMethod.color = UIColor(cashColor()).encode()
            
            do {
                try viewContext.save()
                self.showSheetView = nil
                self.sheetFlag = false
                SPAlert.present(title: "Added to Wallet", preset: .done)
            } catch let createError {
                print("Failed to create PaymentMethod \(createError)")
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
        
        if settings.creditCardReminderEnabled {
            createReminderNotification()
        }
        let ccIdentifier = isIdentifierValidated ? identifierNumber : "XXXX"
        let displayCurrencyValue = getDisplayCurrencyValueFromCurrentAmount()
        
        let newPaymentMethod = editingPaymentMethod ?? PaymentMethod(context: viewContext)
        newPaymentMethod.name = cardName
        newPaymentMethod.balance = displayCurrencyValue
        newPaymentMethod.type = PaymentMethodType.creditCard.rawValue
        newPaymentMethod.identifierNumber = ccIdentifier
        newPaymentMethod.color = UIColor(cardColorSelection).encode()
        
        do {
            try viewContext.save()
            self.showSheetView = nil
            self.sheetFlag = false
            SPAlert.present(title: "Added to Wallet", preset: .done)
        } catch let createError {
            print("Failed to create PaymentMethod \(createError)")
        }
    }
    
    func createEWalletAndDismiss() {
        if (cardName.count == 0) {
            validationAlertMessage = "Please enter your e-Wallet name!"
            showValidationAlert = true
            return
        }
        
        let displayCurrencyValue = getDisplayCurrencyValueFromCurrentAmount()
        
        let newPaymentMethod = editingPaymentMethod ?? PaymentMethod(context: viewContext)
        newPaymentMethod.name = cardName
        newPaymentMethod.balance = displayCurrencyValue
        newPaymentMethod.type = PaymentMethodType.eWallet.rawValue
        newPaymentMethod.color = UIColor(cardColorSelection).encode()
        
        do {
            try viewContext.save()
            self.showSheetView = nil
            self.sheetFlag = false
            SPAlert.present(title: "Added to Wallet", preset: .done)
        } catch let createError {
            print("Failed to create PaymentMethod \(createError)")
        }
    }
    
    func createReminderNotification() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier == NotificationsName.creditCardNotification {
                  identifiers.append(notification.identifier)
               }
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        let content = UNMutableNotificationContent()
        content.title = NotificationsName.creditCardNotificationTitle
        content.subtitle = NotificationsName.creditCardNotificationDescription
        content.sound = UNNotificationSound.default
        
        let nextReminderDate: Date = settings.creditCardNotificationDate
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: nextReminderDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create the request
        let creditCardNotificationName = NotificationsName.creditCardNotification
        let request = UNNotificationRequest(identifier: creditCardNotificationName,
                    content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
    
    func createDebitCardAndDismiss() {
        if (cardName.count == 0) {
            validationAlertMessage = "Please enter your card name!"
            showValidationAlert = true
            return
        }
        
        if (amount == 0) {
            validationAlertMessage = "Please enter your card balance"
            showValidationAlert = true
            return
        }
        
        let debitIdentifier = isIdentifierValidated ? identifierNumber : "XXXX"
        let displayCurrencyValue = getDisplayCurrencyValueFromCurrentAmount()
        
        let newPaymentMethod = editingPaymentMethod ?? PaymentMethod(context: viewContext)
        newPaymentMethod.name = cardName
        newPaymentMethod.balance = displayCurrencyValue
        newPaymentMethod.type = PaymentMethodType.debitCard.rawValue
        newPaymentMethod.identifierNumber = debitIdentifier
        newPaymentMethod.color = UIColor(cardColorSelection).encode()
        
        do {
            try viewContext.save()
            self.showSheetView = nil
            self.sheetFlag = false
            SPAlert.present(title: "Added to Wallet", preset: .done)
        } catch let createError {
            print("Failed to create PaymentMethod \(createError)")
        }
        
    }
    
    func cancel() {
        showSheetView = nil
        sheetFlag = false
    }
    
    func getDisplayCurrencyValueFromCurrentAmount() -> DisplayCurrencyValue {
        let amountString = numOfDecimalPoint == 0 ? String(format: "%.0f", amount) : String(amount)
        let currency = CurrencyValue(amount: amountString, currency: self.currencyText)
        return DisplayCurrencyValue(currencyValue: currency, numOfDecimalPoint: self.numOfDecimalPoint, decimalSeparator: self.decimalSeparator, groupingSeparator: self.groupingSeparator)
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
    var type: PaymentMethodType
    var typeName: String {
        return type == .eWallet ? "E-Wallet" : "Card"
    }
    var namePreview: String {
        return type == .eWallet ? "G*pay/OV*/..." : "BC*/Mandir*/..."
    }
    
    var body: some View {
        VStack {
            Text("\(typeName) Styling")
                .font(.footnote)
                .foregroundColor(.init(.secondaryLabel))
                .padding(.top)
            VStack {
                HStack {
                    Text("\(typeName) Name")
                    TextField(namePreview, text: $cardName)
                        .multilineTextAlignment(.trailing)
                        .introspectTextField(customize: UITextField.introspect())
                }
                Divider()
                if type != .eWallet {
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
                }
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

struct CurrencyFormattingView: View {
    
    @Binding var numOfDecimalPoint: Int
    @Binding var decimalSeparator: String
    @Binding var groupingSeparator: String
    @Binding var currencyText: String!
    
    var body: some View {
        VStack {
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
    }
}

struct PaymentMethodReminderSetupView: View {
    
    @Binding var monthlyReminderOn: Bool
    @Binding var monthlyReminderDate: Date
    
    var body: some View {
        VStack {
            Text("Reminder")
                .font(.footnote)
                .foregroundColor(.init(.secondaryLabel))
                .padding(.top)
            VStack {
                HStack {
                    Toggle(isOn: $monthlyReminderOn, label: {
                        Text("Monthly Reminder").foregroundColor(Color(.label))
                    })
                }.padding(.horizontal)
                .onChange(of: monthlyReminderOn, perform: { value in
                    if value {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                            if success {
                                print("Notifications enabled")
                            } else if error != nil {
                                monthlyReminderOn = false
                            }
                        }
                    }
                })
                if monthlyReminderOn {
                    Divider().padding(.horizontal)
                    DatePicker("", selection: $monthlyReminderDate)
                        .padding(.horizontal).foregroundColor(Color(.label))
                }
            }
            .foregroundColor(.init(.quaternaryLabel))
            .padding(.vertical)
            .background(Color.init(.secondarySystemBackground)
                            .cornerRadius(.normal))
            .opacity(0.7)
            HStack {
                Spacer()
                Text("Select date for your next reminder")
                    .font(.caption)
                    .foregroundColor(.init(.tertiaryLabel))
            }
            HStack {
                Spacer()
                Text("You will be reminded every month of exact day and time")
                    .font(.caption)
                    .foregroundColor(.init(.tertiaryLabel))
            }
        }
    }
}
