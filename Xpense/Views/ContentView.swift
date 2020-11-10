//
//  ContentView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import PartialSheet
import LocalAuthentication
import Firebase

struct ContentView: View {
    
    static var appUnlocked = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [])
    private var paymentMethods: FetchedResults<PaymentMethod>
    
    @State private var selection: Int = 1
    @State var navigationBarTitle: String = "Xpense"
    @State var showModally = true
    @State var addTransaction = false
    @State var addTransactionRefreshFlag = UUID()
    @State var introSheet: SheetFlags? = nil
    
    @ObservedObject var settings = UserSettings()
    @State private var isUnlocked = false
    
    var body: some View {
        VStack {
            if isUnlocked || !settings.securityEnabled {
                NavigationView {
                    TabView(selection: $selection) {
                        XpenseView(uuid: $addTransactionRefreshFlag).tabItem {
                            Image("xpense")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                            Text("Xpense")
                        }.tag(1)
                        WalletView()
                            .tabItem {
                            Image(systemName: "creditcard")
                            Text("Wallet")
                        }.tag(2)
                        ReportsView().tabItem {
                            Image(systemName: "chart.bar.doc.horizontal")
                            Text("Reports")
                        }.tag(3)
                        SettingsView(parentIntroSheet: $introSheet, parentTabSelection: $selection).tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }.tag(4)
                    }.sheet(isPresented: self.$addTransaction) {
                        AddExpenseView(showSheetView: self.$addTransaction, refreshFlag: $addTransactionRefreshFlag)
                            .environment(\.managedObjectContext, self.viewContext)
                    }
                    .navigationBarItems(trailing: Button(action: {
                        Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                            "screenName": "Add Transaction"
                        ])
                        self.addTransaction.toggle()
                    }, label: {
                        Image(systemName: "note.text.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(1.2)
                    }))
                    .navigationBarTitle(self.navigationBarTitle)
                    .onChange(of: selection, perform: { value in
                        switch value {
                        case 1:
                            self.navigationBarTitle = "Xpense"
                            Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                                "screenName": "Xpense"
                            ])
                        case 2:
                            self.navigationBarTitle = "Wallet"
                            Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                                "screenName": "Wallet"
                            ])
                        case 3:
                            self.navigationBarTitle = "Reports"
                            Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                                "screenName": "Reports"
                            ])
                        case 4:
                            self.navigationBarTitle = "Settings"
                            Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                                "screenName": "Settings"
                            ])
                        default:
                            break
                        }
                    })
                }
                .onAppear {
                    if !settings.hasSetupIntro {
                        self.introSheet = .intro
                    }
                    else {
                        self.checkPaymentMethods()
                    }
                    Analytics.setDefaultEventParameters(
                    [
                        "userName": settings.userName,
                        "userEmail": settings.userEmail
                    ])
                }
                .addPartialSheet()
                .accentColor(.theme)
                .sheet(item: $introSheet) { item in
                    switch item {
                    case .wallet:
                        CreatePaymentMethodView(paymentMethodType: .cash, showSheetView: $introSheet)
                            .presentation(isModal: self.$showModally) {
                                print("Attempted to dismiss")
                            }
                            .accentColor(.theme)
                            .environment(\.managedObjectContext, self.viewContext)
                            .navigationViewStyle(StackNavigationViewStyle())
                    case .intro:
                        NavigationView {
                            IntroScreenView(showSheetView: $introSheet).presentation(isModal: self.$showModally) {
                                print("Attempted to dismiss")
                            }
                        }.presentation(isModal: self.$showModally) {
                            print("Attempted to dismiss")
                        }
                        .accentColor(.theme)
                    default:
                        EmptyView()
                    }
                }
            }
            else {
                VStack {
                    HStack {
                        Text("Xpense")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    .padding(.bottom, .large)
                    HStack {
                        Image(systemSymbol: .faceid)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding()
                        Text("/")
                            .font(.largeTitle)
                        Image(systemName: "touchid")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding()
                    }
                    .padding()
                    .padding(.top, .extraLarge)
                    Text("Locked")
                        .bold()
                    PrimaryButton(title: "Authenticate") {
                        authenticate()
                    }
                    Spacer()
                }.padding()
                .onAppear {
                    authenticate()
                    Analytics.setDefaultEventParameters(
                    [
                        "userName": settings.userName,
                        "userEmail": settings.userEmail
                    ])
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func deletePaymentMethods() {
        for method in paymentMethods {
            viewContext.delete(method)
        }
        try! viewContext.save()
    }
    
    func checkPaymentMethods() {
        if paymentMethods.count == 0 {
            self.introSheet = .wallet
        }
    }
    
    func authenticate() {
        if !ContentView.appUnlocked {
            let context = LAContext()
            var error: NSError?

            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // it's possible, so go ahead and use it
                let reason = "Only you can unlock your app"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    // authentication has now completed
                    DispatchQueue.main.async {
                        if success {
                            isUnlocked = true
                            ContentView.appUnlocked = true
                            Analytics.logEvent(AnalyticsEventLogin, parameters: [:])
                        } else {
                            isUnlocked = false
                            ContentView.appUnlocked = false
                        }
                    }
                }
            } else {
                isUnlocked = false
                ContentView.appUnlocked = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
