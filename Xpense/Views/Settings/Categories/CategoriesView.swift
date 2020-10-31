//
//  CategoriesView.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct CategoriesView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var segmentIndex: Int = 0
    let segments:[CategoryType] = CategoryType.allCases
    @State var addCategoryFlag: Bool =  false
    @State var newCategoryType: CategoryType = .income
    @State var selectedCategory: CategoryModel? = nil
    @State private var refreshID = UUID()
    var selectionAction:((CategoryModel) -> Void)? = nil
    var migrationSelection: CategoryModel?
    
    var body: some View {
        VStack {
            if let migration = migrationSelection {
                HStack {
                    Text("To receive transaction migration from \(migration.name ?? "")")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.footnote)
                    Spacer()
                }.padding(.horizontal)
            }
            Picker(selection: self.$segmentIndex, label: Text("")) {
                ForEach(0..<self.segments.count) { index in
                    Text(self.segments[index].rawValue)
                }
            }
            .padding()
            .pickerStyle(SegmentedPickerStyle())
            CategoriesGrid(fetchRequest: makeFetchRequest(), categoryTapAction: onCategoryTapped(category:), refreshFlag: $refreshID)
                .id(refreshID)
        }
        .sheet(isPresented: $addCategoryFlag, content: {
            NavigationView {
                NewCategoryView(showSheetView: $addCategoryFlag, existingCategory: $selectedCategory, categoryType: newCategoryType, refreshFlagUUID: $refreshID).environment(\.managedObjectContext, self.viewContext)
            }.accentColor(.theme)
        })
        .navigationTitle(migrationSelection != nil ? "Select Category" : "Categories")
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                if migrationSelection == nil {
                    Menu {
                        Section {
                            Button(action: {
                                selectedCategory = nil
                                newCategoryType = .income
                                addCategoryFlag.toggle()
                            }) {
                                Label {
                                    Text("New Income Category")
                                } icon: {
                                    Image(systemSymbol: .plusCircle)
                                }
                            }
                            Button(action: {
                                selectedCategory = nil
                                newCategoryType = .expense
                                addCategoryFlag.toggle()
                            }) {
                                Label {
                                    Text("New Expense Category")
                                } icon: {
                                    Image(systemSymbol: .minusCircle)
                                }
                            }
                        }
                    }
                    label: {
                        Label("Add", systemImage: "rectangle.stack.fill.badge.plus")
                    }
                }
            }
        })
    }
    
    func makeFetchRequest() -> FetchRequest<CategoryModel> {
        let type = CategoryType.allCases[self.segmentIndex].rawValue
        var predicate = NSPredicate(format: "type == %@", type)
        if let migration = migrationSelection {
            predicate = NSPredicate(format: "type == %@ && SELF != %@", type, migration)
        }
        let sort = NSSortDescriptor(key: "timeStamp", ascending: true)
        return FetchRequest<CategoryModel>(entity: CategoryModel.entity(), sortDescriptors: [sort], predicate: predicate, animation: .spring())
    }
    
    func onCategoryTapped(category: CategoryModel) {
        if let action = selectionAction {
            action(category)
        }
        else {
            //workaround
            selectedCategory = nil
            selectedCategory = category
            
            DispatchQueue.main.async {
                newCategoryType = .expense
                selectedCategory = category
                addCategoryFlag.toggle()
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
