//
//  AddExpenseView.swift
//  Xpense
//
//  Created by Teddy Santya on 27/9/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct AddExpenseView: View {
    
    @Binding var showSheetView: Bool
    @State var amount: String = ""
    @State var notes: String = ""
    
    init(showSheetView:Binding<Bool>) {
        self._showSheetView = showSheetView
        UITextView.appearance().backgroundColor = .clear
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center) {
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
                    Text("Shopping")
                        .bold()
                        .padding(.top, .small)
                    HStack {
                        Spacer()
                        ForEach(0 ..< 3) { item in
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(gradient: .init(colors: [lighterOrange(), .init(.systemOrange)]), startPoint: .top, endPoint: .bottom)
                                        )
                                        .frame(width: 50, height: 50)
                                    Image(systemSymbol: .archiveboxFill)
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                }.padding(.top, .large)
                                Text("Food")
                                    .bold()
                                    .font(.caption)
                                    .padding(.top, .tiny)
                                    .padding(.bottom, .medium)
                            }
                            Spacer()
                        }
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(
                                        Color.blue.opacity(0.5)
                                    )
                                    .frame(width: 50, height: 50)
                                Image(systemSymbol: .ellipsis)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.blue)
                            }.padding(.top, .large)
                            Text("More")
                                .bold()
                                .font(.caption)
                                .padding(.top, .tiny)
                                .padding(.bottom, .medium)
                        }
                        Spacer()
                    }
                    VStack {
                        Text("Enter amount")
                            .font(.footnote)
                            .foregroundColor(.init(.secondaryLabel))
                        TextField("Rp. 0", text: self.$amount)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.init(.secondarySystemBackground))
                            .cornerRadius(.normal)
                    }.padding(.horizontal)
                    HStack {
                        VStack {
                            Image(systemName: "cylinder.split.1x2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(.top)
                                .padding(.bottom, .tiny)
                            Text("Rp. 10,000")
                                .padding(.bottom)
                        }.frame(minWidth: 50, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .background(Color.init(.secondarySystemBackground))
                        .cornerRadius(.normal)
                        .font(.caption)
                        VStack {
                            Image(systemName: "cylinder.split.1x2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(.top)
                                .padding(.bottom, .tiny)
                            Text("Rp. 20,000")
                                .padding(.bottom)
                        }.frame(minWidth: 50, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .background(Color.init(.secondarySystemBackground))
                        .cornerRadius(.normal)
                        .font(.caption)
                        VStack {
                            Image(systemName: "cylinder.split.1x2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(.top)
                                .padding(.bottom, .tiny)
                            Text("Rp. 50,000")
                                .padding(.bottom)
                        }.frame(minWidth: 50, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .background(Color.init(.secondarySystemBackground))
                        .cornerRadius(.normal)
                        .font(.caption)
                        VStack {
                            Image(systemName: "cylinder.split.1x2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(.top)
                                .padding(.bottom, .tiny)
                            Text("Rp. 100,000")
                                .padding(.bottom)
                        }.frame(minWidth: 50, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .background(Color.init(.secondarySystemBackground))
                        .cornerRadius(.normal)
                        .font(.caption)
                    }
                    .padding(.horizontal)
                    Text("Select Payment Method")
                        .font(.footnote)
                        .foregroundColor(.init(.secondaryLabel))
                        .padding(.top)
                    ScrollView (.horizontal, showsIndicators: false) {
                        let width = CGFloat(150)
                        let height = CGFloat(80)
                        HStack {
                            PaymentMethodCardView(color: .systemGreen, title: "Rupiah")
                                .frame(width: width, height: height)
                            PaymentMethodCardView(color: .systemPurple, title: "OVO")
                                .frame(width: width, height: height)
                            PaymentMethodCardView(color: .systemBlue, title: "BCA")
                                .frame(width: width, height: height)
                        }
                        .padding(.horizontal)
                    }.frame(height: 80)
                    ZStack {
                        Color.init(.secondarySystemBackground)
                            .cornerRadius(.normal)
                        ZStack(alignment: .topLeading) {
                            let labelText = notes.count > 0 ? notes : "Notes"
                            let textColor = notes.count > 0 ? Color.init(.label) : Color.init(.tertiaryLabel)
                            Text(labelText)
                                .padding([.leading, .trailing], 5)
                                .padding([.top, .bottom], 8)
                                .foregroundColor(textColor)
                            TextEditor(text: self.$notes)
                        }
                        .padding(.small)
                    }
                    .padding()
                    .frame(minHeight: 200)
                }
            }.navigationBarTitle(Text("Add Expense"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.showSheetView = false
            }) {
                Text("Cancel").bold()
            }, trailing: Button(action: {
                self.showSheetView = false
            }) {
                Text("Add").bold()
            })
        }
        .accentColor(.theme)
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

struct PaymentMethodCardView: View {
    
    var color: UIColor
    var title: String
    
    var body: some View {
        ZStack(alignment:.bottomTrailing) {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.init(color.lighter(by: 10.0)!), Color.init(color), Color.init(color.darker(by: 30.0)!)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(title)
                .font(.callout)
                .bold()
                .padding()
                .foregroundColor(.white)
        }
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddExpenseView(showSheetView: Binding<Bool>(get: {
            return true
        }, set: { (flag) in
            
        }))
        .environment(\.colorScheme, .dark)
    }
}
