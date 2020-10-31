//
//  XpenseView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import CoreData

struct XpenseView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<TransactionModel>
    var transactions : FetchedResults<TransactionModel>{fetchRequest.wrappedValue}
    @State var progressValue: Float = 1.0
    @State var showAddBudget: Bool = false
    @Binding var refreshFlag: UUID
    var transactionLimit: Int {
        transactions.count > 3 ? 3 : transactions.count
    }
    
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
                            showAddBudget.toggle()
                        }
                    }
                    .padding([.horizontal, .bottom])
                    HStack {
                        Text("Transactions")
                            .font(Font.getFontFromDesign(design: .sectionTitle))
                        Spacer()
                        NavigationLink(destination: TransactionListView()) {
                            Text("See All")
                                .font(.getFontFromDesign(design: .buttonTitle))
                        }
                    }.padding(.horizontal)
                    .padding(.top, .small)
                    LazyVStack {
                        ForEach(0..<transactionLimit) { index in
                            if index < transactions.count {
                                let transaction = transactions[index]
                                TransactionCellView(transaction: transaction, refreshFlag: $refreshFlag)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .id(refreshFlag)
        }.onAppear(perform: {
            withAnimation {
                self.progressValue = 0.5
            }
            refreshFlag = UUID()
        })
        .sheet(isPresented: $showAddBudget, content: {
            NavigationView {
                AddBudgetView(showSheetView: $showAddBudget)
                    .environment(\.managedObjectContext, self.viewContext)
            }.accentColor(.theme)
        })
    }
    
    init(uuid: Binding<UUID>) {
        _refreshFlag = uuid
        let request: NSFetchRequest<TransactionModel> = TransactionModel.fetchRequest()
        request.fetchLimit = 3
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest = FetchRequest<TransactionModel>(fetchRequest: request)
    }
}

struct XpenseView_Previews: PreviewProvider {
    static var previews: some View {
        XpenseView(uuid: .init(get: { () -> UUID in
            return UUID()
        }, set: { (uuid) in
            
        }))
    }
}
