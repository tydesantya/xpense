//
//  PaymentMethodMigrationSelectionView.swift
//  Xpense
//
//  Created by Teddy Santya on 7/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import Firebase

struct PaymentMethodMigrationSelectionView: View {
    
    @State var showAlert = false
    @State var selectedPaymentMethod: PaymentMethod? = nil
    var excludedPaymentMethod: PaymentMethod
    
    var fetchRequest: FetchRequest<PaymentMethod>
    var paymentMethods: FetchedResults<PaymentMethod> {
        fetchRequest.wrappedValue
    }
    var migrateAction:(PaymentMethod, PaymentMethod) -> (Void)
    
    var flexibleLayout = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: flexibleLayout, spacing: .small) {
                    ForEach(paymentMethods) {
                        paymentMethod in
                        PaymentMethodCardView(paymentMethod: paymentMethod, selectedPaymentMethod: .constant(nil), customAction: {
                            selectedPaymentMethod = paymentMethod
                            showAlert = true
                        })
                        .aspectRatio(CGSize(width: 1.0, height: 0.5), contentMode: .fit)
                    }
                }.padding()
            }.alert(isPresented: $showAlert, content: {
                Alert(title: Text("Confirmation"), message: Text("Are you sure you want to delete and migrate \(excludedPaymentMethod.name ?? "") transactions to \(selectedPaymentMethod?.name ?? "") ?"), primaryButton: .destructive(Text("Migrate")) {
                    migrateAction(excludedPaymentMethod, selectedPaymentMethod!)
                }, secondaryButton: .cancel())
            })
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    AnalyticsParameterScreenName: "Migrate Payment Method"
                ])
            }
        }.navigationTitle("Select Payment Method")
    }
    
    init(excludedPaymentMethod: PaymentMethod, migrateAction:@escaping (PaymentMethod, PaymentMethod) -> (Void)) {
        self.excludedPaymentMethod = excludedPaymentMethod
        self.migrateAction = migrateAction
        let predicate = NSPredicate(format: "SELF != %@", excludedPaymentMethod)
        fetchRequest = FetchRequest<PaymentMethod>(entity: PaymentMethod.entity(), sortDescriptors: [], predicate: predicate, animation: .spring())
    }
}
