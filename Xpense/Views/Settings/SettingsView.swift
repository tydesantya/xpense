//
//  SettingsView.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import CoreData
import StoreKit

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var navigate: Bool = false
    @State var destinationView: AnyView?
    @ObservedObject var settings = UserSettings()
    @State var showConfirmationAlert: Bool = false
    @Binding var parentIntroSheet: SheetFlags?
    @Binding var parentTabSelection: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Transaction")
                    .font(.getFontFromDesign(design: .sectionTitle))
                VStack {
                    LazyVStack {
                        MenuView(iconName: "largecircle.fill.circle", text: "Budget", action: self.menuTapped(title:))
                        Divider()
                            .padding(.bottom, .tiny)
                        MenuView(iconName: "rectangle.stack.fill", text: "Categories", action: self.menuTapped(title:))
                    }
                }
                .padding()
                .background(Color.init(.secondarySystemBackground))
                .cornerRadius(.medium)
                Text("System")
                    .font(.getFontFromDesign(design: .sectionTitle))
                    .padding(.top)
                VStack {
                    LazyVStack {
                        MenuView(iconName: "lock.fill", text: "Security", action: self.menuTapped(title:))
                        Divider()
                            .padding(.bottom, .tiny)
                        MenuView(iconName: "scroll.fill", text: "Terms & Conditions", action: self.menuTapped(title:))
                        Divider()
                            .padding(.bottom, .tiny)
                        MenuView(iconName: "hand.raised.fill", text: "Privacy Policy", action: self.menuTapped(title:))
                        Divider()
                            .padding(.bottom, .tiny)
                        MenuView(iconName: "mail.fill", text: "Feedback", action: self.menuTapped(title:))
                        Divider()
                            .padding(.bottom, .tiny)
                        MenuView(iconName: "star.fill", text: "Rate This App", action: self.menuTapped(title:))
                    }
                }
                .padding()
                .background(Color.init(.secondarySystemBackground))
                .cornerRadius(.medium)
                PrimaryButton(title: "Erase All Content And Setting", action:  {
                    showConfirmationAlert = true
                }, destructive: true).padding(.top, .extraLarge)
                NavigationLink(
                    destination: destinationView,
                    isActive: self.$navigate,
                    label: {
                        EmptyView()
                    })
            }
            .padding()
            .alert(isPresented: $showConfirmationAlert) {
                Alert(title: Text("Warning"), message: Text("Are you sure you want to delete all data ?\nThis Operation cannot be undone"), primaryButton: .destructive(Text("Delete")) {
                    deleteAllData()
                }, secondaryButton: .cancel())
            }
        }
        .padding(.top, 0.3)
        .navigationBarTitle("Settings")
    }
    
    func menuTapped(title: String) {
        var shouldNavigate = true
        switch title {
        case "Budget":
            destinationView = AnyView(BudgetSettingsView())
        case "Categories":
            print("temp todo")
            destinationView = AnyView(
                CategoriesView()
                    .environment(\.managedObjectContext, self.viewContext)
            )
        case "Privacy Policy":
            destinationView = AnyView(
                PrivacyPolicyView()
            )
        case "Terms & Conditions":
            destinationView = AnyView(
                TermsOfUseView()
            )
        case "Security":
            destinationView = AnyView(
                SetupSecurityView()
            )
        case "Feedback":
            destinationView = AnyView(
                FeedbackView()
            )
        case "Rate This App":
            if let scene = UIApplication.shared.currentScene {
                SKStoreReviewController.requestReview(in: scene)
                settings.hasRequestReview = true
                shouldNavigate = false
            }
        default:
            destinationView = nil
        }
        if shouldNavigate {
            self.navigate = true
        }
    }
    
    func deleteAllData() {
        deleteAllBudget()
        deleteAllTransactions()
        deleteAllPaymentMethods()
        deleteAllCategories()
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        UIApplication.shared.validateCategoriesSeed()
        parentTabSelection = 1
        parentIntroSheet = .intro
    }
    
    func deleteAllCategories() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CategoryModel.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
        } catch let error  {
            print("failed to batch delete \(error)")
        }
    }
    
    func deleteAllPaymentMethods() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PaymentMethod.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
        } catch let error  {
            print("failed to batch delete \(error)")
        }
    }
    
    func deleteAllTransactions() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TransactionModel.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
        } catch let error  {
            print("failed to batch delete \(error)")
        }
    }
    
    func deleteAllBudget() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PeriodicBudget.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let budgetRequest: NSFetchRequest<NSFetchRequestResult> = Budget.fetchRequest()
        let budgetDeleteRequest = NSBatchDeleteRequest(fetchRequest: budgetRequest)
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.execute(budgetDeleteRequest)
        } catch let error  {
            print("failed to batch delete \(error)")
        }
    }
}

struct MenuView: View {
    
    var iconName: String
    var text: String
    var action: (String) -> Void
    
    var body: some View {
        Button(action: {
            self.action(text)
        }) {
            HStack {
                Image(systemName: iconName)
                    .frame(width: 25)
                Text(text)
                    .font(.getFontFromDesign(design: .buttonTitle))
                    .foregroundColor(Color.init(.label))
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(parentIntroSheet: .constant(nil), parentTabSelection: .constant(1))
    }
}
