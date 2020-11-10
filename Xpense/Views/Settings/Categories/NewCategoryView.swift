//
//  NewCategoryView.swift
//  Xpense
//
//  Created by Teddy Santya on 22/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SFSafeSymbols
import SPAlert
import Firebase

struct NewCategoryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var showSheetView: Bool
    @State var categoryName: String = ""
    @State var newStyleSheet: Bool = false
    @State var newStyleSheetType: CategoryStyleType = .emoji
    @State var color: Color = Color(UIColor.systemGreen)
    var lighterColor: Color {
        Color(UIColor(color).lighter()!)
    }
    @State var customTextIcon: String? = nil
    @State var symbolSelection: SFSymbol = .bagFill
    @Binding var existingCategory: CategoryModel?
    var categoryType: CategoryType
    @Binding var refreshFlagUUID: UUID
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    newStyleSheetType = .text
                    newStyleSheet.toggle()
                }, label: {
                    ZStack {
                        Circle()
                            .fill(
                                Color.blue.opacity(0.5)
                            )
                            .frame(width: 60, height: 60)
                        Image(systemSymbol: .pencil)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }.padding(.top, .large)
                })
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(gradient: .init(colors: [lighterColor, color]), startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 100, height: 100)
                    if let text = customTextIcon {
                        Text(text)
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    else {
                        Image(systemSymbol: symbolSelection)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }
                }.padding(.top, .large)
                Spacer()
                Button(action: {
                    newStyleSheetType = .emoji
                    newStyleSheet.toggle()
                }, label: {
                    ZStack {
                        Circle()
                            .fill(
                                Color.blue.opacity(0.5)
                            )
                            .frame(width: 60, height: 60)
                        Image(systemSymbol: .smileyFill)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }.padding(.top, .large)
                })
                Spacer()
            }.padding(.top)
            HStack {
                TextField("Category Name", text: self.$categoryName)
                    .font(.sectionTitle)
                    .multilineTextAlignment(.center)
                    .keyboardType(.alphabet)
                    .padding()
                    .background(Color.init(.secondarySystemBackground))
                    .cornerRadius(.normal)
                    .introspectTextField(customize: UITextField.introspect())
            }.padding()
            ProvidedCategoriesScrollView(colorSelection: $color, customTextIcon: $customTextIcon, symbolSelection: $symbolSelection, moreIconAction: onMoreIconTapped)
        }
        .onAppear {
            onAppear()
        }
        .sheet(isPresented: $newStyleSheet, content: {
            NewCategoryStyleView(type: $newStyleSheetType, showSheetFlag: $newStyleSheet, completion: onUserSelectTextOrEmojiWithText).accentColor(.theme)
        })
        .navigationBarTitle(Text(getNavigationBarTitle()), displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            self.showSheetView = false
        }) {
            Text("Cancel").bold()
        }, trailing: Button(action: {
            onDoneTapped()
        }) {
            Text("Done").bold()
        })
    }
    
    func onAppear() {
        Analytics.logEvent(AnalyticsEventScreenView, parameters:[
            "screenName": "New Category"
        ])
        if let category = existingCategory {
            categoryName = category.name ?? ""
            symbolSelection = SFSymbol(rawValue: category.symbolName ?? "") ?? .bagFill
            color = Color(UIColor.color(data: category.color!)!)
            customTextIcon = category.text
        }
    }
    
    func getNavigationBarTitle() -> String {
        if let category = existingCategory {
            return "Edit \(category.name ?? "")"
        }
        return "New \(categoryType.rawValue)"
    }
    
    func onUserSelectTextOrEmojiWithText(text: String?, color: Color, symbol: SFSymbol?) {
        self.color = color
        self.customTextIcon = text
        if let symbol = symbol {
            self.symbolSelection = symbol
        }
    }
    
    func onMoreIconTapped() {
        newStyleSheetType = .icon
        newStyleSheet.toggle()
    }
    
    func onDoneTapped() {
        if let category = existingCategory {
            Analytics.logEvent("edit_category", parameters: [
                "categoryName": categoryName,
                "categoryType": categoryType.rawValue
            ])
            editExistingCategory(category)
        }
        else {
            Analytics.logEvent("create_category", parameters: [
                "categoryName": categoryName,
                "categoryType": categoryType.rawValue
            ])
            createNewCategory()
        }
    }
    
    func createNewCategory() {
        let category = CategoryModel(context: viewContext)
        category.name = categoryName
        category.type = categoryType.rawValue
        category.symbolName = symbolSelection.rawValue
        category.color = UIColor(color).encode()
        category.lighterColor = UIColor(lighterColor).encode()
        category.text = customTextIcon
        category.timeStamp = Date()
        
        do {
            try viewContext.save()
            self.showSheetView = false
            SPAlert.present(title: "Added Category", preset: .done)
        } catch let createError {
            print("Failed to create Category \(createError)")
        }
    }
    
    func editExistingCategory(_ category: CategoryModel) {
        category.name = categoryName
        category.symbolName = symbolSelection.rawValue
        category.color = UIColor(color).encode()
        category.lighterColor = UIColor(lighterColor).encode()
        category.text = customTextIcon
        
        do {
            try viewContext.save()
            refreshFlagUUID = UUID()
            self.showSheetView = false
            SPAlert.present(title: "Edited Category", preset: .done)
        } catch let createError {
            print("Failed to edit Category \(createError)")
        }
    }
}

private struct ProvidedCategoriesScrollView: View {
    
    @Binding var colorSelection: Color
    @Binding var customTextIcon: String?
    @Binding var symbolSelection: SFSymbol
    var moreIconAction: () -> (Void)
    
    var flexibleLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var emojis:[String] {
        [
            "🍔","🍗","🍎","🍸",
            "🚗","🚕","🛵","✈️",
            "🛒","🛍","🍿","📸"
        ]
    }
    var colorTemplates:[Color] {
        [
            Color(UIColor.systemGray),
            Color(UIColor.systemPink),
            Color(UIColor.systemRed),
            Color(UIColor.systemOrange),
            
            Color(UIColor.systemYellow),
            Color(UIColor.systemGreen),
            Color(UIColor.systemBlue),
            Color(UIColor.systemPurple),
            
            Color(UIColor.systemTeal),
            Color(UIColor.systemIndigo),
            Color(UIColor.link),
            Color(UIColor.systemFill)
        ]
    }
    
    var sfSymbols:[SFSymbol] {
        [
            .plus,
            .archiveboxFill,
            .archivebox,
            .envelope,
            
            .musicMic,
            .hifispeaker,
            .car,
            .airplane,
            
            .bagFill,
            .bag,
            .video,
            .gamecontroller
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Emoji")
                    .padding([.top, .horizontal])
                LazyVGrid(columns: flexibleLayout, spacing: .small) {
                    ForEach(0 ..< emojis.count) { index in
                        let emoji = emojis[index]
                        let color = colorTemplates[index]
                        let lighterColor = Color(UIColor(color).lighter()!)
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(gradient: .init(colors: [lighterColor, color]), startPoint: .top, endPoint: .bottom)
                                )
                                .padding(.tiny)
                            Text(emoji)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            self.colorSelection = color
                            self.customTextIcon = emoji
                        }
                        .aspectRatio(1, contentMode: .fill)
                    }
                }.padding(.horizontal)
                Text("Icons")
                    .padding([.top, .horizontal])
                LazyVGrid(columns: flexibleLayout, spacing: .small) {
                    ForEach(0 ..< sfSymbols.count) { index in
                        let maxIndex = sfSymbols.count - 1
                        let symbol:SFSymbol = sfSymbols[index]
                        let color = index == 0 ? Color.blue.opacity(0.5) : colorTemplates[maxIndex - index]
                        let lighterColor = Color(UIColor(color).lighter()!)
                        let foregroundColor: Color = index == 0 ? .blue : .white
                        ZStack {
                            if (index == 0) {
                                Circle()
                                    .fill(color)
                                    .padding(.tiny)
                            }
                            else {
                                Circle()
                                    .fill(
                                        LinearGradient(gradient: .init(colors: [lighterColor, color]), startPoint: .top, endPoint: .bottom)
                                    )
                                    .padding(.tiny)
                            }
                            Image(systemSymbol: symbol)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(foregroundColor)
                        }
                        .onTapGesture {
                            if (index == 0) {
                                moreIconAction()
                            }
                            else {
                                self.colorSelection = color
                                self.customTextIcon = nil
                                self.symbolSelection = symbol
                            }
                        }
                        .aspectRatio(1, contentMode: .fill)
                    }
                }.padding(.horizontal)
            }
        }
    }
}

struct NewCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewCategoryView(showSheetView: .init(get: { () -> Bool in
                return true
            }, set: { (flag) in
                
            }), existingCategory: .init(get: { () -> CategoryModel? in
                return nil
            }, set: { (flag) in
                
            }), categoryType: .income, refreshFlagUUID: .init(get: { () -> UUID in
                return UUID()
            }, set: { (id) in
                
            }))
        }.accentColor(.theme)
        .environment(\.colorScheme, .dark)
    }
}
