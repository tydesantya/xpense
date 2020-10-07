//
//  WalletView.swift
//  Xpense
//
//  Created by Teddy Santya on 7/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct WalletView: View {
    var body: some View {
        GeometryReader { reader in
            ScrollView {
                VStack {
                    VStack {
                        Text("TOTAL BALANCE")
                            .bold()
                            .padding(.top)
                            .padding(.bottom, .tiny)
                        Text("Rp. 1,000,000,000")
                            .font(.huge)
                    }.frame(minWidth: 100, maxWidth: .infinity)
                    HStack {
                        Text("Cash")
                            .bold()
                            .padding(.horizontal, 50)
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
                            .bold()
                            .padding(.horizontal, 50)
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
                    }
                    HStack {
                        EmptyView()
                        Spacer()
                    }
                    .frame(height: 100)
                }
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

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
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
                .shadow(color: shadowColor, radius: 10.0, x: 0.0, y: 10.0)
            Rectangle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .padding()
                .opacity(0.0)
        }
    }
}
