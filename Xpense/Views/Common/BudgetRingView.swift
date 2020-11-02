//
//  BudgetRingView.swift
//  Xpense
//
//  Created by Teddy Santya on 3/11/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import SwiftUI

struct BudgetRingView: View {
    
    @State var budgetsProgress:[Float] = [1.0, 1.0, 1.0]
    var periodicBudget: PeriodicBudget
    var largestSize: CGFloat
    
    var body: some View {
        if let budgets = periodicBudget.budgets {
            let budgetsArray = budgets.allObjects as! [Budget]
            let sortedBudgetsArray = budgetsArray.sorted { (first, second) -> Bool in
                return first.order < second.order
            }
            let initialSize = largestSize
            ZStack {
                ForEach(sortedBudgetsArray, id:\.self) {
                    budget in
                    let category = budget.category!
                    let categoryColorData = category.color!
                    let categoryUiColor = UIColor.color(data: categoryColorData)!
                    let index = sortedBudgetsArray.firstIndex(of: budget)
                    let size = initialSize - CGFloat((index! * 30))
                    ProgressBar(progress: $budgetsProgress[index!], color: categoryUiColor)
                        .frame(width: size, height: size)
                        .padding(.vertical)
                        .onAppear {
                            withAnimation {
                                let limit = budget.limit
                                let limitAmount = limit!.toDouble()
                                
                                let used = budget.usedAmount
                                let usedAmount = used!.toDouble()
                                
                                let progress = 1 - usedAmount / limitAmount
                                budgetsProgress[index!] = Float(progress)
                            }
                            
                        }
                }
            }
        }
    }
}

