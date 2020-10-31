//
//  AddBudgetView.swift
//  Xpense
//
//  Created by Teddy Santya on 31/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct AddBudgetView: View {
    
    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [
        ]
    ) var budgets: FetchedResults<Budget>
    @State var selectedCategories: [CategoryModel] = []
    @State private var refreshID = UUID()
    @Binding var showSheetView: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Select Up To 3 Categories To Setup Budget")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.footnote)
                    Spacer()
                }.padding(.horizontal)
                HStack {
                    Spacer()
                    ForEach(selectedCategories, id: \.self) {
                        category in
                        let width:CGFloat = 50.0
                        let height:CGFloat = 50.0
                        ZStack(alignment: .topTrailing) {
                            CategoryIconDisplayView(category: category, iconWidth: width, iconHeight: height)
                                .onTapGesture {
                                    selectedCategories.remove(at: selectedCategories.firstIndex(of: category)!)
                                }
                            ZStack(alignment: .center) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 15, height: 15)
                                Image(systemSymbol: .xmark)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                }.frame(maxWidth: .infinity, minHeight: 80)
                .background(
                    RoundedRectangle(cornerRadius: .medium)
                        .fill(Color(UIColor.secondarySystemBackground))
                ).padding()
                .padding()
                .pickerStyle(SegmentedPickerStyle())
                CategoriesGrid(fetchRequest: makeFetchRequest(), categoryTapAction: onCategoryTapped(category:), refreshFlag: $refreshID)
                    .id(refreshID)
            }
        }.navigationTitle("Setup Budget")
        .navigationBarItems(leading: Button(action: {
            self.showSheetView = false
        }) {
            Text("Cancel").bold()
        }, trailing: Button(action: {
//            if amount == 0 {
//                showValidationAlert.toggle()
//            }
//            else if let transaction = selectedTransaction {
//                editTransaction(transaction)
//            }
//            else {
//                createTransaction()
//            }
        }) {
            Text("Next").bold()
        }.disabled(selectedCategories.count == 0))
        .onAppear {
            print("budget count \(budgets.count)")
            for budget in budgets {
                print("check budget \(budget.period)")
                print("check budget \(budget.category)")
                print("check budget \(budget.amount)")
            }
        }
    }
    
    
    func makeFetchRequest() -> FetchRequest<CategoryModel> {
        let type = CategoryType.expense.rawValue
        var predicateString = "type == %@"
        var argumentArray: [Any] = [type]
        for category in selectedCategories {
            predicateString.append(" && SELF != %@")
            argumentArray.append(category)
        }
        let predicate = NSPredicate(format: predicateString, argumentArray: argumentArray)
        let sort = NSSortDescriptor(key: "timeStamp", ascending: true)
        return FetchRequest<CategoryModel>(entity: CategoryModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func onCategoryTapped(category: CategoryModel) {
        if selectedCategories.count < 3 {
            selectedCategories.append(category)
        }
    }
}
