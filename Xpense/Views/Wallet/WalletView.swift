//
//  WalletView.swift
//  Xpense
//
//  Created by Teddy Santya on 7/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct WalletView: View {
    
    @State var showCreditCardList: Bool = false
    
    var body: some View {
        GeometryReader { reader in
            ScrollView {
                VStack {
                    HStack {
                        Text("Overview")
                            .font(Font.getFontFromDesign(design: .sectionTitle))
                        Spacer()
                    }.padding([.top, .horizontal])
                    VStack(alignment: .leading, spacing: .small) {
                        Text("Rp. 1,000,000,000")
                            .font(.huge)
                        HStack {
                            Text("Total Balance")
                            Spacer()
                        }
                    }.padding()
                    .background(
                        Color.init(.secondarySystemBackground)
                            .cornerRadius(.medium)
                    )
                    .padding(.horizontal)
                    HStack {
                        Text("Cash")
                            .font(Font.getFontFromDesign(design: .sectionTitle))
                            .padding(.horizontal)
                            .padding(.top, .large)
                        Spacer()
                    }
                    ZStack {
                        PaymentMethodCard(backgroundColor: cashColor(), shadowColor: cashShadowColor())
                        VStack {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    PlaceHolderView()
                                        .frame(width: 150, height: 5)
                                    PlaceHolderView()
                                        .frame(width: 100, height: 5)
                                    PlaceHolderView()
                                        .frame(width: 50, height: 5)
                                    Spacer()
                                }
                                Spacer()
                            }.frame(height: 50)
                            HStack {
                                VStack(alignment: .leading) {
                                    Spacer()
                                    Text("Rp. 100,000")
                                        .bold()
                                        .foregroundColor(.white)
                                    Text("Total cash")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Text("Rp.")
                                    .font(.hugeTitle)
                                    .foregroundColor(.white)
                                    .opacity(0.5)
                            }
                        }.padding()
                    }.frame(width: reader.size.width - 100, height: 150)
                    HStack {
                        Text("Debit Cards")
                            .font(Font.getFontFromDesign(design: .sectionTitle))
                            .padding(.horizontal)
                            .padding(.top, .large)
                        Spacer()
                    }
                    ZStack {
                        ZStack {
                            PaymentMethodCard(backgroundColor: bcaColor(), shadowColor: bcaShadowColor())
                        }.frame(width: reader.size.width - 100 - 40, height: 160)
                        ZStack {
                            PaymentMethodCard(backgroundColor: bniColor(), shadowColor: bniShadowColor())
                        }
                        .frame(width: reader.size.width - 100 - 20, height: 160)
                        .offset(y: 10.0)
                        ZStack {
                            PaymentMethodCard(backgroundColor: mandiriColor(), shadowColor: mandiriShadowColor())
                            VStack {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        PlaceHolderView()
                                            .frame(width: 150, height: 5)
                                        PlaceHolderView()
                                            .frame(width: 100, height: 5)
                                        PlaceHolderView()
                                            .frame(width: 50, height: 5)
                                    }
                                    Spacer()
                                    Text("Mandiri")
                                        .bold()
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                VStack(alignment: .center) {
                                    Text("XXXX XXXX XXXX 4159")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                HStack {
                                    Text("Teddy Santya")
                                        .bold()
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }.padding()
                        }
                        .frame(width: reader.size.width - 100, height: 160)
                        .offset(y: 20.0)
                    }.onTapGesture {
                        self.showCreditCardList.toggle()
                    }
                    HStack {
                        Text("Credit Cards")
                            .font(Font.getFontFromDesign(design: .sectionTitle))
                            .padding(.horizontal)
                            .padding(.top, .medium)
                        Spacer()
                    }
                    .padding(.top, .large)
                    AddCardPlaceholder(text: "Add Credit Card")
                        .frame(width: reader.size.width - 100, height: 150)
                    HStack {
                        Text("E-Wallet")
                            .font(Font.getFontFromDesign(design: .sectionTitle))
                            .padding(.horizontal)
                            .padding(.top, .medium)
                        Spacer()
                    }
                    .padding(.top, .normal)
                    AddCardPlaceholder(text: "Add E-Wallet")
                        .frame(width: reader.size.width - 100, height: 150)
                        .padding(.bottom, .large)
                }
            }
        }
        .sheet(isPresented: self.$showCreditCardList) {
            NavigationView {
                CreditCardListDetailView()
            }
        }
    }
    
    func bniColor() -> Color {
        return Color.init(UIColor.systemOrange.darker()!)
    }
    
    func bniShadowColor() -> Color {
        return Color.init(UIColor.systemOrange).opacity(0.5)
    }
    
    func bcaColor() -> Color {
        return Color.init(UIColor.systemBlue)
    }
    
    func bcaShadowColor() -> Color {
        return Color.init(UIColor.systemBlue.lighter()!).opacity(0.5)
    }
    
    func mandiriColor() -> Color {
        return Color.init(UIColor.systemBlue.darker()!)
    }
    
    func mandiriShadowColor() -> Color {
        return Color.init(UIColor.systemBlue).opacity(0.5)
    }
    
    func cashShadowColor() -> Color {
        return Color.init(UIColor.systemGreen).opacity(0.5)
    }
    
    func cashColor() -> Color {
        return Color.init(UIColor.systemGreen.darker()!)
    }
}

struct PlaceHolderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 50)
            .fill(placeholderColor())
    }
    
    func placeholderColor() -> Color {
        let uiColor: UIColor = UIColor.gray.lighter()!
        return Color.init(uiColor)
    }
}

struct PaymentMethodCard: View {
    var backgroundColor: Color
    var shadowColor: Color
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .cornerRadius(10.0)
                .shadow(radius: 10.0)
            Rectangle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .padding()
                .opacity(0.0)
        }
    }
}

struct AddCardPlaceholder: View {
        
    var text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(
                    Color.blue.opacity(0.5)
                )
            RoundedRectangle(cornerRadius: 10.0)
                .strokeBorder(Color.blue)
            VStack {
                Image(systemSymbol: .plus)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.blue)
                    .padding()
                Text(text)
                    .bold()
                    .foregroundColor(.blue)
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
