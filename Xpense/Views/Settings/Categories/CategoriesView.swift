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
    
    var body: some View {
        VStack {
            Picker(selection: self.$segmentIndex, label: Text("")) {
                ForEach(0..<self.segments.count) { index in
                    Text(self.segments[index].rawValue)
                }
            }
            .padding()
            .onChange(of: self.segmentIndex, perform: { value in
                self.segmentChanged(value)
            })
            .pickerStyle(SegmentedPickerStyle())
            CategoriesGrid(fetchRequest: makeFetchRequest())
        }
        .sheet(isPresented: $addCategoryFlag, content: {
            NavigationView {
                NewCategoryView(showSheetView: $addCategoryFlag, categoryType: newCategoryType)
            }.accentColor(.theme)
        })
        .navigationTitle("Categories")
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Section {
                        Button(action: {
                            newCategoryType = .income
                            addCategoryFlag.toggle()
                        }) {
                            Label {
                                Text("New Income Category")
                            } icon: {
                                Image(systemSymbol: .arrowDownCircleFill)
                                    .foregroundColor(.init(.systemGreen))
                            }
                        }
                        Button(action: {
                            newCategoryType = .expense
                            addCategoryFlag.toggle()
                        }) {
                            Label {
                                Text("New Expense Category")
                            } icon: {
                                Image(systemSymbol: .arrowUpCircleFill)
                                    .foregroundColor(.init(.systemRed))
                            }
                        }
                    }
                }
                label: {
                    Label("Add", systemImage: "plus").padding()
                }
            }
        })
    }
    
    func makeFetchRequest() -> FetchRequest<CategoryModel> {
        let type = CategoryType.allCases[self.segmentIndex].rawValue
        let predicate = NSPredicate(format: "type == %@", type)
        
        return FetchRequest<CategoryModel>(entity: CategoryModel.entity(), sortDescriptors: [], predicate: predicate, animation: .spring())
    }
    
    func segmentChanged(_ index: Int) {
        
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
