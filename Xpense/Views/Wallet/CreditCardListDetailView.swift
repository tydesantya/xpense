//
//  CreditCardListDetailView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct CreditCardListDetailView: View {
    
    @State var destinationView: AnyView?
    @State var navigate: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationLink(
                destination: destinationView,
                isActive: self.$navigate,
                label: {
                    EmptyView()
                })
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: .tiny) {
                        Text("Debit Cards")
                            .font(.sectionTitle)
                            .bold()
                        Text("Total Balance: Rp. 100,000,000")
                    }
                    Spacer()
                    Button(action: {
                        // Add Card
                    }) {
                        Image(systemSymbol: .plusCircleFill)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.theme)
                    }
                }
                .padding()
                .background(Color.init(.secondarySystemBackground))
                ViewPager()
                    .frame(height: 220)
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: .tiny) {
                            Text("Mandiri")
                                .font(.subheadline)
                                .bold()
                            Text("Balance: Rp. 100,000,000")
                                .font(.footnote)
                        }
                        Spacer()
                        Button(action: {
                            // Add Card
                        }) {
                            VStack {
                                Image(systemSymbol: .pencil)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color.init(.label))
                                Text("Edit Card")
                                    .font(.caption2)
                                    .foregroundColor(Color.init(.label))
                            }
                        }
                    }
                    .padding()
                    Divider()
                    ScrollView {
                        LazyVStack {
                            HStack {
                                Text("Transactions")
                                    .font(.subheadline)
                                    .bold()
                                Spacer()
                            }
                            ForEach(0..<50) { index in
                                TransactionCellView(category: Category(name: "Shopping", icon: UIImage(systemName: "bag.fill")!, color: .purple), navigationDestination: navigateToView(_:))
                            }
                        }
                        .padding()
                        .background(Color.init(.systemBackground))
                    }
                }
                .background(Color.init(.secondarySystemBackground))
            }
            .edgesIgnoringSafeArea(.bottom)
            Button(action: {
                
            }) {
                HStack {
                    Image(systemSymbol: .sliderHorizontal3)
                        .font(.getFontFromDesign(design: .buttonTitle))
                    Text("Sort & Filter")
                        .font(.getFontFromDesign(design: .buttonTitle))
                }
                .padding(.vertical, .small)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.theme)
                        .shadow(radius: 5)
                )
                .foregroundColor(.white)
            }
        }
        .navigationBarHidden(true)
    }
    
    func navigateToView(_ destination: AnyView?) {
        if let view = destination {
            destinationView = view
            self.navigate.toggle()
        }
    }
}

struct CreditCardListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CreditCardListDetailView()
    }
}

struct ViewPager: View {
    var body: some View {
        TabView {
            ForEach(0..<30) { i in
                ZStack {
                    PaymentMethodCard(backgroundColor: mandiriColor())
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
            }
            .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fit)
            .padding(.top, 80)
            .offset(y: -50)
        }
        .background(Color.init(.secondarySystemFill))
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
    
    func mandiriColor() -> Color {
        return Color.init(UIColor.systemBlue.darker()!)
    }
    
    func mandiriShadowColor() -> Color {
        return Color.init(UIColor.systemBlue).opacity(0.5)
    }
}
