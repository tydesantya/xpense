//
//  BudgetSettingsView.swift
//  Xpense
//
//  Created by Teddy Santya on 4/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import CoreData
import SPAlert

struct BudgetSettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: PeriodicBudget.entity(),
        sortDescriptors: [
        ],
        predicate: NSPredicate(format: "startDate <= %@ && endDate >= %@", Date() as NSDate, Date() as NSDate)
    ) var periodicBudgets: FetchedResults<PeriodicBudget>
    
    var navigationTitle: String {
        "\(periodicBudgets.first?.period ?? "") Budget"
    }
    
    @State var optionAction: Bool = false
    @State var showConfirmationAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                if let periodBudget = periodicBudgets.first {
                    BudgetRingView(periodicBudget: periodBudget, largestSize: 200.0, lineWidth: 25)
                        .padding()
                    Divider()
                        .padding()
                    Text("Budget Amount and Order")
                        .font(.sectionTitle)
                        .padding(.bottom)
                    ForEach(periodBudget.budgets!.allObjects as! [Budget]) {
                        budget in
                        let category = budget.category!
                        HStack {
                            Spacer()
                            Spacer()
                            CategoryIconDisplayView(category: category, iconWidth: 80.0, iconHeight: 80.0)
                                .padding()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(category.name ?? "")
                                    Text(budget.limit!.toString())
                                        .font(.sectionTitle)
                                        .padding()
                                        .background(Color(UIColor.secondarySystemBackground).cornerRadius(.normal))
                                        .onTapGesture {
                                            optionAction.toggle()
                                        }
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(height: 100)
                    }
                }
                else {
                    BudgetPreviewView()
                }
            }
            .actionSheet(isPresented: $optionAction, content: {
                ActionSheet(title: Text("Options"), message: Text("Delete this budget to setup new budget"), buttons: [
                    .destructive(Text("Delete")) {
                        showConfirmationAlert.toggle()
                    },
                    .cancel()
                ])
            })
            .alert(isPresented: $showConfirmationAlert) {
                Alert(title: Text("Warning"), message: Text("Are you sure you want to delete all budget entries ?"), primaryButton: .destructive(Text("Delete")) {
                    deleteAllBudget()
                }, secondaryButton: .cancel())
            }
        }.navigationTitle(navigationTitle)
        .navigationBarItems(trailing: Button(action: {
            optionAction.toggle()
        }) {
            Image(systemSymbol: .ellipsis)
                .padding()
        })
    }
    
    func makeSelectedDateBudgetFetchRequest() -> FetchRequest<PeriodicBudget> {
        let predicate = NSPredicate(format: "startDate <= %@ && endDate >= %@", Date() as NSDate, Date() as NSDate)
        return FetchRequest<PeriodicBudget>(entity: PeriodicBudget.entity(), sortDescriptors: [], predicate: predicate, animation: .spring())
    }
    
    func deleteAllBudget() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PeriodicBudget.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        let budgetRequest: NSFetchRequest<NSFetchRequestResult> = Budget.fetchRequest()
        let budgetDeleteRequest = NSBatchDeleteRequest(fetchRequest: budgetRequest)
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.execute(budgetDeleteRequest)
            SPAlert.present(title: "Budget Deleted", preset: .done)
            presentationMode.wrappedValue.dismiss()
        } catch let error  {
            print("failed to batch delete \(error)")
        }
    }
}

struct BudgetSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetSettingsView()
    }
}
