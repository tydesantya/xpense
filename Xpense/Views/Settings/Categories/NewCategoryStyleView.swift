//
//  NewCategoryStyleView.swift
//  Xpense
//
//  Created by Teddy Santya on 22/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

enum CategoryStyleType: String {
    case text = "Text"
    case emoji = "Emoji"
}

struct NewCategoryStyleView: View {
    
    @State var colorSelection: Color = Color(UIColor.systemPurple)
    @State var colorSelectionLighter: Color = Color(UIColor.systemPurple.lighter()!)
    @State var inputText: String = ""
    @State var latestInputText: String = ""
    @Binding var type: CategoryStyleType
    @Binding var showSheetFlag: Bool
    @State var segmentIndex: Int = 0
    @State var hasPerformOnAppear = false
    var segments: [String] {
        [type.rawValue, "Style"]
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(gradient: .init(colors: [colorSelectionLighter, colorSelection]), startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 200, height: 200)
                        .onChange(of: colorSelection, perform: { value in
                            colorSelectionLighter = Color(UIColor(colorSelection).lighter()!)
                        })
                    getTextInput()
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
                if (segmentIndex == 1) {
                    VStack {
                        Text("Pick the accent color").bold()
                            .padding(.top)
                        ColorPicker(selection: $colorSelection) {
                            
                        }
                        .frame(width: 0, height: 200)
                        .scaleEffect(4)
                        .offset(x: -15)
                    }
                }
            }.navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.showSheetFlag = false
            }) {
                Text("Cancel").bold()
            }, trailing: Button(action: {
                self.showSheetFlag = false
            }) {
                Text("Done").bold()
            })
            .onAppear {
                segmentChanged(0)
            }
        }
    }
    
    func getTextInput() -> AnyView {
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
        default:
            return AnyView(
                EmojiTextField(text: $inputText)
                    .frame(width: 200, height: 200)
                    .onChange(of: inputText, perform: { value in
                        if value.count > 1 {
                            inputText = latestInputText
                            return
                        }
                        latestInputText = value
                    })
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(EmojiKeyboardNotification.didFocus.rawValue))) { _ in
                        segmentIndex = 0
                    }
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

struct NewCategoryStyleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NewCategoryStyleView(type: .init(get: { () -> CategoryStyleType in
                return .emoji
            }, set: { (type) in
                
            }), showSheetFlag: .init(get: { () -> Bool in
                return true
            }, set: { (flag) in
                
            }))
            NewCategoryStyleView(type: .init(get: { () -> CategoryStyleType in
                return .emoji
            }, set: { (type) in
                
            }), showSheetFlag: .init(get: { () -> Bool in
                return true
            }, set: { (flag) in
                
            }))
            .previewDevice("iPhone 8")
        }
    }
}
