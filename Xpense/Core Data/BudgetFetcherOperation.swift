//
//  BudgetFetcherOperation.swift
//  Xpense
//
//  Created by Teddy Santya on 31/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation
import CoreData
class BudgetFetcherOperation: Operation {
    
    let persistenceController = PersistenceController.shared
    
    override func main() {
        if isCancelled {
            return
        }
        
        let container = persistenceController.container
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<Budget>(entityName: "Budget")
        let categoriesRequest = NSFetchRequest<CategoryModel>(entityName: "Category")
        
        if isCancelled {
            return
        }
        do {
            let category = try context.fetch(categoriesRequest)
            let budget = try context.fetch(fetchRequest)
            if budget.count == 0 {
                let newBudget = Budget(context: context)
                newBudget.category = category.first!
                newBudget.amount = DisplayCurrencyValue(currencyValue: CurrencyValue(amount: "100000", currency: "IDR"), numOfDecimalPoint: 0, decimalSeparator: ",", groupingSeparator: ".")
                newBudget.period = "Daily"
                
                try context.save()
            }
        } catch let fetchError {
            print("Failed to fetch and create budget \(fetchError)")
        }
    }
}
