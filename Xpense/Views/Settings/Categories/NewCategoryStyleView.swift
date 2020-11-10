//
//  NewCategoryStyleView.swift
//  Xpense
//
//  Created by Teddy Santya on 22/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import SFSafeSymbols
import Firebase

enum CategoryStyleType: String {
    case text = "Text"
    case emoji = "Emoji"
    case icon = "Icon"
}

struct NewCategoryStyleView: View {
    
    @State var colorSelection: Color = Color(UIColor.systemGreen)
    @State var colorSelectionLighter: Color = Color(UIColor.systemGreen.lighter()!)
    @State var inputText: String = ""
    @State var latestInputText: String = ""
    @Binding var type: CategoryStyleType
    @Binding var showSheetFlag: Bool
    @State var segmentIndex: Int = 0
    @State var hasPerformOnAppear = false
    @State var symbolSelection: SFSymbol = SFSymbol.allCases.randomElement()!
    var segments: [String] {
        [type.rawValue, "Style"]
    }
    var completion:(String?, Color, SFSymbol?) -> Void
    var flexibleLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var colorTemplates: [Color] {
        [
            Color(UIColor.systemGray),
            Color(UIColor.systemPink),
            Color(UIColor.systemRed),
            Color(UIColor.systemOrange),
            Color(UIColor.systemYellow),
            Color(UIColor.systemGreen),
            Color(UIColor.systemBlue),
            Color(UIColor.systemPurple)
        ]
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.showSheetFlag = false
                }) {
                    Text("Cancel").bold()
                }
                Spacer()
                Button(action: {
                    if self.type == .icon {
                        self.completion(nil, colorSelection, symbolSelection)
                    }
                    else {
                        self.completion(inputText, colorSelection, nil)
                    }
                    self.showSheetFlag = false
                }) {
                    Text("Done").bold()
                }.disabled(inputText.count == 0 && self.type != .icon)
            }
            .padding()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(gradient: .init(colors: [colorSelectionLighter, colorSelection]), startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 200, height: 200)
                    .onChange(of: colorSelection, perform: { value in
                        colorSelectionLighter = Color(UIColor(colorSelection).lighter()!)
                    })
                getTextInputOrImage()
            }.padding(.top, 50)
            Picker(selection: self.$segmentIndex, label: Text("")) {
                ForEach(0..<self.segments.count) { index in
                    Text(String(self.segments[index]))
                }
            }.padding(.top, .extraLarge)
            .padding()
            .onChange(of: self.segmentIndex, perform: { value in
                self.segmentChanged(value)
            })
            .pickerStyle(SegmentedPickerStyle())
            if (segmentIndex == 0 && self.type == .icon) {
                SearchBar(text: $inputText)
                    .padding(.bottom)
            }
            ScrollView {
                if (segmentIndex == 0 && self.type == .icon) {
                    SfSymbolsHGridView(search: $inputText, symbolSelection: $symbolSelection)
                }
                else if (segmentIndex == 1) {
                    VStack {
                        LazyVGrid(columns: flexibleLayout, spacing: .small) {
                            ForEach(0 ..< colorTemplates.count) { index in
                                let color = colorTemplates[index]
                                let lighterColor = Color(UIColor(color).lighter()!)
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(gradient: .init(colors: [lighterColor, color]), startPoint: .top, endPoint: .bottom)
                                        )
                                        .padding(.tiny)
                                    getSmallTextOrImage()
                                }
                                .onTapGesture {
                                    self.colorSelection = color
                                }
                                .aspectRatio(1, contentMode: .fill)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        HStack {
                            ColorPicker(selection: $colorSelection) {
                                Text("Custom Color:")
                            }
                            .frame(width: 150)
                        }
                        .padding()
                        .background(Color.init(.secondarySystemBackground)
                                        .cornerRadius(.normal))
                    }.padding(.top)
                }
            }
        }.navigationBarTitle(Text(""), displayMode: .inline)
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                "screenName": "New Category Style"
            ])
            segmentChanged(0)
        }
        
    }
    
    func getSmallTextOrImage() -> AnyView {
        switch type {
        case .icon:
            return AnyView(
                Image(systemSymbol: symbolSelection)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            )
        default:
            return AnyView(
                Text(inputText)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            )
        }
    }
    
    func getTextInputOrImage() -> AnyView {
        switch type {
        case .text:
            return AnyView(
                TextField("", text: $inputText, onEditingChanged: { focused in
                    if (focused) {
                        segmentIndex = 0
                    }
                })
                .textCase(.uppercase)
                .keyboardType(.alphabet)
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .frame(width: 200, height: 200)
                .foregroundColor(.white)
                .onChange(of: inputText, perform: { value in
                    inputText = inputText.uppercased()
                    if value.count > 2 {
                        inputText = latestInputText
                        return
                    }
                    latestInputText = value
                })
                .introspectTextField(customize: { (textField) in
                    if segmentIndex == 0 {
                        textField.becomeFirstResponder()
                    }
                })
            )
        case .emoji:
            return AnyView(
                EmojiTextField(text: $inputText)
                    .frame(width: 200, height: 200)
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(EmojiKeyboardNotification.didFocus.rawValue))) { _ in
                        segmentIndex = 0
                    }
            )
        case .icon:
            return AnyView(
                Image(systemSymbol: symbolSelection)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            )
        }
    }
    
    func segmentChanged(_ index: Int) {
        if (index == 0) {
            switch type {
            case .emoji:
                NotificationCenter.default.post(Notification(name: Notification.Name(EmojiKeyboardNotification.show.rawValue)))
            default:
                print("Do nothing")
            }
        }
        else {
            switch type {
            case .emoji:
                NotificationCenter.default.post(Notification(name: Notification.Name(EmojiKeyboardNotification.hide.rawValue)))
            default:
                UIApplication.shared.endEditing()
            }
        }
    }
}

struct SfSymbolsHGridView: View {
    
    @Binding var search: String
    @Binding var symbolSelection: SFSymbol
    
    var flexibleLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var allSymbols: [SFSymbol] = SFSymbol.allCases
    var symbols:[SFSymbol] {
        if (search.count > 0) {
            let searchedSymbols = allSymbols.filter { (symbol) -> Bool in
                symbol.rawValue.lowercased().contains(search.lowercased())
            }
            return searchedSymbols
        }
        return allSymbols
    }
    
    var body: some View {
        HStack {
            let layout = symbols.count < flexibleLayout.count ? Array(flexibleLayout[0..<symbols.count]) : flexibleLayout
            LazyVGrid(columns: layout, spacing: .small) {
                ForEach(symbols, id: \.self) {
                    symbol in
                    ZStack {
                        Image(systemSymbol: symbol)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .padding()
                            .onTapGesture {
                                symbolSelection = symbol
                            }
                    }.aspectRatio(1, contentMode: .fit)
                }
            }.padding(.horizontal)
        }
    }
}

struct NewCategoryStyleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NewCategoryStyleView(type: .init(get: { () -> CategoryStyleType in
                return .emoji
            }, set: { (type) in
                
            }), showSheetFlag: .init(get: { () -> Bool in
                return true
            }, set: { (flag) in
                
            }), completion: {
                text, color, image  in
            })
            .previewDevice("iPhone 8")
        }
    }
}
