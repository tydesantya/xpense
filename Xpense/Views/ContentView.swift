//
//  ContentView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [])
    private var paymentMethods: FetchedResults<PaymentMethod>
    
    @State private var selection: Int = 1
    @State var navigationBarTitle: String = "Xpense"
    @State var neverSetupCash = false
    @State var showModally = true
    @State var addTransaction = false
    @State var addTransactionRefreshFlag = UUID()
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                XpenseView(uuid: $addTransactionRefreshFlag).tabItem {
                    Image(systemName: "x.circle")
                    Text("Xpense")
                }.tag(1)
                WalletView().tabItem {
                    Image(systemName: "creditcard")
                    Text("Wallet")
                }.tag(2)
                ReportsView().tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("Reports")
                }.tag(3)
                SettingsView().tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }.tag(4)
            }.sheet(isPresented: self.$addTransaction) {
                AddExpenseView(showSheetView: self.$addTransaction, refreshFlag: $addTransactionRefreshFlag)
                    .environment(\.managedObjectContext, self.viewContext)
            }
            .navigationBarItems(trailing: Button(action: {
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
                case 2:
                    self.navigationBarTitle = "Wallet"
                case 3:
                    self.navigationBarTitle = "Reports"
                case 4:
                    self.navigationBarTitle = "Settings"
                default:
                    break
                }
            })
        }
        .onAppear {
            self.checkPaymentMethods()
        }
        .sheet(isPresented: self.$neverSetupCash, content: {
            CreatePaymentMethodView(paymentMethodType: .cash, sheetFlag: self.$neverSetupCash)
                .presentation(isModal: self.$showModally) {
                    print("Attempted to dismiss")
                }
                .accentColor(.theme)
                .environment(\.managedObjectContext, self.viewContext)
        })
        .accentColor(.theme)
    }
    
    func deletePaymentMethods() {
        for method in paymentMethods {
            viewContext.delete(method)
        }
        try! viewContext.save()
    }
    
    func checkPaymentMethods() {
        if paymentMethods.count == 0 {
            self.neverSetupCash = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
