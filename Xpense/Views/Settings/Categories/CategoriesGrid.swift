//
//  CategoriesGrid.swift
//  Xpense
//
//  Created by Teddy Santya on 26/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SFSafeSymbols
import SPAlert

struct CategoriesGrid: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<CategoryModel>
    private var data: FetchedResults<CategoryModel> {
        fetchRequest.wrappedValue
    }
    var categoryTapAction:(CategoryModel) -> Void
    @State var showDeleteConfirmation = false
    @State var longPressedCategory: CategoryModel? = nil
    
    var flexibleLayout = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: flexibleLayout, spacing: .small) {
                ForEach(data) { category in
                    CategoryItem(category: category)
                        .onTapGesture {
                            categoryTapAction(category)
                        }
                        .contextMenu {
                            Button(action: {
                                longPressedCategory = category
                                showDeleteConfirmation.toggle()
                            }) {
                                Label {
                                    Text("Delete").foregroundColor(.red)
                                } icon: {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }.foregroundColor(.red)
                            }
                        }
                        .actionSheet(isPresented: $showDeleteConfirmation, content: {
                            ActionSheet(title: Text("Delete Confirmation"), message: Text("Are you sure you want to delete ?"), buttons: [
                                .destructive(Text("Delete")) {
                                    deleteCategory(longPressedCategory!)
                                },
                                .cancel()
                            ])
                        })
                }
            }
            .padding(.horizontal)
        }
    }
    
    func deleteCategory(_ category: CategoryModel) {
        do {
            viewContext.delete(category)
            try viewContext.save()
            SPAlert.present(title: "Deleted Category", preset: .done)
        } catch let createError {
            print("Failed to delete Category \(createError)")
        }
    }
}

struct CategoryItem: View {
    
    var category: CategoryModel
    var customTextIcon: String? {
        category.text
    }
    var categoryLighterColor: Color {
        Color(UIColor.color(data: category.color!)!.lighter(by: 10.0)!)
    }
    var categoryColor: Color {
        Color(UIColor.color(data: category.color!)!)
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
            }
            ZStack {
                Circle().fill(Color.init(UIColor.color(data: category.color!)!))
                    .frame(width: 40, height: 40)
                if let text = customTextIcon {
                    Text(text)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                else {
                    if let symbolName = category.symbolName {
                        Image(systemSymbol: SFSymbol(rawValue: symbolName) ?? .bagFill)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                }
            }
            Text(category.name ?? "")
                .bold()
                .foregroundColor(.white)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
        .background(
            LinearGradient(gradient: Gradient(colors: [categoryLighterColor, categoryColor]), startPoint: .center, endPoint: .trailing)
        )
        .cornerRadius(.normal)
    }
}
