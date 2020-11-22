//
//  XpenseView.swift
//  Xpense
//
//  Created by Teddy Santya on 8/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI
import CoreData
import Firebase
import StoreKit

struct XpenseView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<TransactionModel>
    var transactions : FetchedResults<TransactionModel>{fetchRequest.wrappedValue}
    @Binding var refreshFlag: UUID
    var transactionLimit: Int {
        transactions.count > 3 ? 3 : transactions.count
    }
    
    @FetchRequest(
        entity: PeriodicBudget.entity(),
        sortDescriptors: [
        ],
        predicate: NSPredicate(format: "startDate <= %@ && endDate >= %@", Date() as NSDate, Date() as NSDate)
    ) var periodicBudgets: FetchedResults<PeriodicBudget>
    
    let categoryNotification = NotificationCenter.default
        .publisher(for: NSNotification.Name("CategoryUpdated"))
    @ObservedObject var settings = UserSettings()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    if periodicBudgets.count > 0 {
                        BudgetHomeView(periodicBudgets: periodicBudgets)
                    }
                    else {
                        BudgetPreviewView()
                    }
                    HStack {
                        Text("Transactions")
                            .font(.sectionTitle)
                        Spacer()
                        NavigationLink(destination: TransactionListView()) {
                            Text("See All")
                        }
                    }.padding(.horizontal)
                    .padding(.top)
                    LazyVStack {
                        ForEach(0..<transactionLimit) { index in
                            if index < transactions.count {
                                let transaction = transactions[index]
                                TransactionCellView(transaction: transaction, refreshFlag: $refreshFlag)
                            }
                        }
                        if transactions.count == 0 {
                            VStack(spacing: .small) {
                                Text("No Transactions")
                                    .bold()
                                Text("Your Recent Transactions Will Appear Here")
                                    .foregroundColor(Color(.secondaryLabel))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }.frame(minHeight: 200)
                        }
                    }
                    .id(refreshFlag)
                    .padding(.horizontal)
                    HStack {
                        Text("Tips")
                            .font(.sectionTitle)
                        Spacer()
                        NavigationLink(destination: ArticleWebView()) {
                            Text("Read Article")
                        }
                    }.padding(.horizontal)
                    .padding(.top)
                    VStack(alignment: .leading) {
                        Text("4 Simple Ways to Take Control of Your Coronavirus Budget").bold()
                        Text("1. Cancel something").font(.subheadline).bold()
                            .padding(.vertical)
                        Text("Sometimes the task of monitoring and planning your saving and spending feels too big, and the trick is to break down what you’re trying to achieve into smaller parts before starting with the easiest one...")
                            .font(.body)
                        Divider()
                        HStack {
                            Spacer()
                            Text("nytimes.com")
                                .font(.caption)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }.padding()
                    .background(
                        Color.init(.secondarySystemBackground)
                            .cornerRadius(.medium)
                    )
                    .padding([.horizontal, .bottom])
                }
                .id(refreshFlag)
            }
            .padding(.top, 0.3)
        }.onAppear(perform: {
            if transactions.count > 2 && !settings.hasRequestReview {
                if let scene = UIApplication.shared.currentScene {
                    SKStoreReviewController.requestReview(in: scene)
                    settings.hasRequestReview = true
                }
            }
            refreshFlag = UUID()
        })
        .onReceive(categoryNotification, perform: { _ in
            refreshFlag = UUID()
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

struct BudgetHomeView: View {
    
    var periodicBudgets: FetchedResults<PeriodicBudget>
    @State var budgetsProgress:[Float] = [1.0, 1.0, 1.0]
    @State var navigateToBudgetDetail: Bool = false
    
    var body: some View {
        if let periodicBudget = periodicBudgets.first {
            if let budgets = periodicBudget.budgets {
                let budgetsArray = budgets.allObjects as! [Budget]
                let sortedBudgetsArray = budgetsArray.sorted { (first, second) -> Bool in
                    return first.order < second.order
                }
                VStack(alignment: .leading) {
                    Text("\(periodicBudget.period ?? "") Budget")
                        .font(Font.getFontFromDesign(design: .sectionTitle))
                        .padding([.top, .horizontal])
                        .padding(.bottom, .small)
                    HStack(alignment: .center) {
                        Spacer()
                        BudgetRingView(periodicBudget: periodicBudget, largestSize: 120.0)
                        .padding(.trailing, .medium)
                        .padding(.vertical)
                        Spacer()
                        VStack(alignment: .leading) {
                            Spacer()
                            ForEach(sortedBudgetsArray, id: \.self) {
                                budget in
                                let category = budget.category!
                                let categoryColorData = category.color!
                                let categoryUiColor = UIColor.color(data: categoryColorData)!
                                let used = budget.usedAmount
                                let usedAmount = used!.toDouble()
                                let limit = budget.limit
                                let limitAmount = limit!.toDouble()
                                let leftAmount = limitAmount - usedAmount
                                let leftAmountDisplay = DisplayCurrencyValue(currencyValue: CurrencyValue(amount: String(leftAmount), currency: used!.currencyValue.currency), numOfDecimalPoint: used!.numOfDecimalPoint, decimalSeparator: used!.decimalSeparator, groupingSeparator: used!.groupingSeparator)
                                HStack(spacing: .small) {
                                    CategoryIconDisplayView(category: category, iconWidth: 20.0, iconHeight: 20.0)
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 0) {
                                            Text("Budget: ")
                                                .font(.caption)
                                            Text(leftAmount < 0 ? "Over Limit!" : leftAmountDisplay.toString())
                                                .foregroundColor(Color(categoryUiColor))
                                                .bold()
                                                .font(.caption)
                                        }
                                        HStack(spacing: 0) {
                                            Text("Limit: ")
                                                .font(.caption)
                                            Text(limit!.toString())
                                                .font(.caption)
                                                .foregroundColor(Color(categoryUiColor))
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, .small)
                    .frame(maxWidth: .infinity)
                    .background(Color.init(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    NavigationLink(
                        destination: BudgetDetailView(budgetPeriod: BudgetPeriod(rawValue: periodicBudget.period!)!),
                        isActive: $navigateToBudgetDetail,
                        label: {
                            EmptyView()
                        })
                }
                .onTapGesture {
                    Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                        AnalyticsParameterScreenName: "Budget Detail"
                    ])
                    DispatchQueue.main.async {
                        navigateToBudgetDetail = true
                    }
                }
            }
        }
    }
}

struct BudgetPreviewView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var showAddBudget: Bool = false
    @State var budgetsProgress:[Float] = [1.0, 1.0, 1.0]
    var dummyBudget: [DummyBudget] = [
        DummyBudget(color: .systemRed, leftAmountString: "200000", categoryText: "🍔"),
        DummyBudget(color: .systemOrange, leftAmountString: "500000", categoryText: "🏥"),
        DummyBudget(color: .link, leftAmountString: "250000", categoryText: "🍿"),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Budget")
                .font(Font.getFontFromDesign(design: .sectionTitle))
                .padding([.top, .horizontal])
                .padding(.bottom, .small)
            ZStack {
                HStack(alignment: .center) {
                    let initialSize:CGFloat = 120.0
                    Spacer()
                    ZStack {
                        ForEach(dummyBudget, id:\.self) {
                            budget in
                            let index = dummyBudget.firstIndex(of: budget)
                            let size = initialSize - CGFloat((index! * 30))
                            ProgressBar(progress: $budgetsProgress[index!], color: budget.color)
                                .frame(width: size, height: size)
                                .padding(.vertical)
                        }
                    }
                    .padding(.trailing, .medium)
                    .padding(.vertical)
                    Spacer()
                    VStack(alignment: .leading) {
                        Spacer()
                        ForEach(dummyBudget, id:\.self) {
                            budget in
                            let leftAmountDisplay = DisplayCurrencyValue(currencyValue: CurrencyValue(amount: String(budget.leftAmountString), currency: "IDR"), numOfDecimalPoint: 0, decimalSeparator: ",", groupingSeparator: ",")
                            HStack(spacing: .small) {
                                let customTextIcon = budget.categoryText
                                let iconWidth:CGFloat = 20.0
                                let iconHeight:CGFloat = 20.0
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(gradient: .init(colors: [Color(budget.color.lighter()!), Color(budget.color)]), startPoint: .top, endPoint: .bottom)
                                        )
                                        .frame(width: iconWidth, height: iconHeight)
                                    Text(customTextIcon)
                                        .font(.system(size: iconWidth/2, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                }
                                VStack(alignment: .leading) {
                                    HStack(spacing: 0) {
                                        Text("Budget: ")
                                            .font(.caption)
                                        Text(leftAmountDisplay.toString())
                                            .foregroundColor(Color(budget.color))
                                            .bold()
                                            .font(.caption)
                                    }
                                    HStack(spacing: 0) {
                                        Text("Limit: ")
                                            .font(.caption)
                                        Text(leftAmountDisplay.toString())
                                            .font(.caption)
                                            .foregroundColor(Color(budget.color))
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, .small)
                .frame(maxWidth: .infinity)
                .background(Color.init(.secondarySystemBackground))
                .cornerRadius(.medium)
                .padding(.horizontal)
                Blur(style: .systemUltraThinMaterial)
                    .cornerRadius(.medium)
                    .padding(.horizontal)
                    .opacity(0.95)
                VStack(spacing: .normal) {
                    Image(systemName: "gearshape.2")
                    Text("Setup Budget")
                        .font(.sectionTitle)
                        .bold()
                        .shadow(radius: 20)
                }
            }
            .onTapGesture {
                Analytics.logEvent(AnalyticsEventScreenView, parameters:[
                    AnalyticsParameterScreenName: "Add Budget"
                ])
                showAddBudget.toggle()
            }
            .sheet(isPresented: $showAddBudget, content: {
                NavigationView {
                    AddBudgetView(showSheetView: $showAddBudget)
                        .environment(\.managedObjectContext, self.viewContext)
                }.accentColor(.theme)
                .presentation(isModal: .constant(true)) {
                    print("Attempted to dismiss")
                }
                .edgesIgnoringSafeArea(.bottom)
            })
        }
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

struct DummyBudget: Hashable {
    var color: UIColor
    var leftAmountString: String
    var categoryText: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(color)
    }
}
