//
//  NewCategoryView.swift
//  Xpense
//
//  Created by Teddy Santya on 22/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct NewCategoryView: View {
    @Binding var showSheetView: Bool
    @State var categoryName: String = ""
    @State var newStyleSheet: Bool = false
    @State var newStyleSheetType: CategoryStyleType = .emoji
    
    var body: some View {
        ScrollView {
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
                                LinearGradient(gradient: .init(colors: [lighterPurple(), .init(.systemPurple)]), startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 100, height: 100)
                        Image(systemSymbol: .bagFill)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
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
                }
                HStack {
                    TextField("Category Name", text: self.$categoryName)
                        .font(.sectionTitle)
                        .multilineTextAlignment(.center)
                        .keyboardType(.alphabet)
                        .padding()
                        .background(Color.init(.secondarySystemBackground))
                        .cornerRadius(.normal)
                }.padding()
            }
        }
        .sheet(isPresented: $newStyleSheet, content: {
            NavigationView {
                NewCategoryStyleView(type: $newStyleSheetType, showSheetFlag: $newStyleSheet)
            }.accentColor(.theme)
        })
        .navigationBarTitle(Text("Add Category"), displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            self.showSheetView = false
        }) {
            Text("Cancel").bold()
        }, trailing: Button(action: {
            self.showSheetView = false
        }) {
            Text("Done").bold()
        })
    }
    
    func lighterPurple() -> Color {
        let lighterPurple = UIColor.systemPurple.lighter(by: 10.0)
        return Color.init(lighterPurple!)
    }
    
    func lighterOrange() -> Color {
        let lighterOrange = UIColor.systemOrange.lighter(by: 10.0)
        return Color.init(lighterOrange!)
    }
}

struct NewCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewCategoryView(showSheetView: .init(get: { () -> Bool in
                return true
            }, set: { (flag) in
                
            }))
        }.accentColor(.theme)
        .environment(\.colorScheme, .dark)
    }
}
