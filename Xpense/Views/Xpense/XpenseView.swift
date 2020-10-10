//
//  XpenseView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct XpenseView: View {
    
    @State var show = false
    @State var progressValue: Float = 1.0
    @State var showAddExpense: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Daily Budget")
                        .font(Font.getFontFromDesign(design: .sectionTitle))
                        .padding([.top, .horizontal])
                    HStack {
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                ZStack {
                                    ProgressBar(progress: self.$progressValue, color: UIColor.systemBlue)
                                    .frame(width: 40.0, height: 40.0)
                                        .padding(.vertical)
                                    ProgressBar(progress: self.$progressValue, color: UIColor.systemRed)
                                    .frame(width: 70.0, height: 70.0)
                                        .padding(.vertical)
                                    ProgressBar(progress: self.$progressValue, color: UIColor.purple)
                                    .frame(width: 100.0, height: 100.0)
                                        .padding(.vertical)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Spacer()
                                    Text("Shopping")
                                        .font(.footnote)
                                    Text("Rp. 100k/ 100k")
                                        .font(.getFontFromDesign(design: .buttonTitle))
                                        .foregroundColor(.purple)
                                    Spacer()
                                    Text("Foods & Drinks")
                                        .font(.footnote)
                                    Text("Rp. 200k/ 200k")
                                        .font(.getFontFromDesign(design: .buttonTitle))
                                        .foregroundColor(.init(.systemRed))
                                    Spacer()
                                    Text("Transport")
                                        .font(.footnote)
                                    Text("Rp. 50k/ 50k")
                                        .font(.getFontFromDesign(design: .buttonTitle))
                                        .foregroundColor(.init(.systemBlue))
                                    Spacer()
                                }
                                Spacer()
                            }.padding(.horizontal)
                            VStack {
                                ProgressView("Daily Budget: Rp. 175k/ 350k", value: 50, total: 100)
                                    .font(.footnote)
                                    .accentColor(.theme)
                            }
                        }.padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.init(.secondarySystemBackground))
                        .cornerRadius(16)
                        .onTapGesture {
                            
                        }
                    }
                    .padding(.horizontal)
                    PrimaryButton(title: "Add Expense") {
                        self.showAddExpense.toggle()
                    }
                    .padding(.horizontal)
                    HStack {
                        Text("Transactions")
                            .font(Font.getFontFromDesign(design: .sectionTitle))
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.show.toggle()
                            }
                        }) {
                            Text("See All")
                                .font(.getFontFromDesign(design: .buttonTitle))
                        }
                        
                    }.padding(.horizontal)
                    .padding(.top, .small)
                    VStack {
                        ForEach(0..<3) { index in
                            TransactionCellView(category: Category(name: "Shopping", icon: UIImage(systemName: "bag.fill")!, color: .purple))
                        }
                    }
                    .padding(.horizontal)
                }
            }.edgesIgnoringSafeArea([.horizontal])
            if (self.show) {
                GeometryReader {
                    _ in
                    MonthPicker(completion: {
                        month, year in
                        withAnimation {
                            self.show.toggle()
                        }
                        print (month, year)
                    })
                }.background(
                    Blur(style: .systemUltraThinMaterial)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            self.show.toggle()
                        }
                    }
                )
            }
        }.onAppear(perform: {
            withAnimation {
                self.progressValue = 0.5
            }
        })
        .sheet(isPresented: self.$showAddExpense) {
            AddExpenseView(showSheetView: self.$showAddExpense)
        }
    }
}

struct XpenseView_Previews: PreviewProvider {
    static var previews: some View {
        XpenseView()
    }
}
