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
    
    var container: NSPersistentCloudKitContainer { persistenceController.container }
    var viewContext: NSManagedObjectContext { container.viewContext }
    
    override func main() {
        if isCancelled {
            return
        }
        
        let fetchRequest = NSFetchRequest<PeriodicBudget>(entityName: "PeriodicBudget")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        
        if isCancelled {
            return
        }
        do {
            let periodicBudgets = try viewContext.fetch(fetchRequest)
            if let latestPeriodicBudget = periodicBudgets.first { // check if user have ever created budget
                var periodDate = Date()

                while latestPeriodicBudget.endDate! < periodDate { // check if latest budget is not valid anymore
                    // budget is not valid and should create for current period

                    if isCancelled {
                        return
                    }

                    let budgetPeriod = BudgetPeriod(rawValue: latestPeriodicBudget.period!)


                    // create budget for period
                    let newPeriodicBudget = PeriodicBudget(context: viewContext)
                    newPeriodicBudget.period = budgetPeriod!.rawValue
                    switch budgetPeriod {
                    case .daily:
                        newPeriodicBudget.startDate = periodDate.startOfDay
                        newPeriodicBudget.endDate = periodDate.endOfDay
                    case .weekly:
                        newPeriodicBudget.startDate = periodDate.startOfWeek()
                        newPeriodicBudget.endDate = periodDate.endOfWeek
                    case .monthly:
                        newPeriodicBudget.startDate = periodDate.startOfMonth()
                        newPeriodicBudget.endDate = periodDate.endOfMonth
                    default:
                        print("")
                    }

                    for existingBudget in latestPeriodicBudget.budgets!.allObjects as! [Budget] {
                        if isCancelled {
                            return
                        }
                        if let category = existingBudget.category, let limit = existingBudget.limit {
                            let budget = Budget(context: viewContext)
                            budget.category = category
                            budget.limit = limit
                            budget.usedAmount = DisplayCurrencyValue(currencyValue: CurrencyValue(amount: "0", currency: limit.currencyValue.currency), numOfDecimalPoint: 0, decimalSeparator: ",", groupingSeparator: ".")
                            budget.periodicBudget = newPeriodicBudget
                            budget.order = existingBudget.order
                        }
                    }


                    // change to previous period
                    var components = DateComponents()
                    switch budgetPeriod {
                    case .daily:
                        components.day = -1
                    case .weekly:
                        components.day = -7
                    case .monthly:
                        components.month = -1
                    case .none:
                        print("error")
                    }

                    periodDate = Calendar.iso8601.date(byAdding: components, to: periodDate)!
                }

                try viewContext.save()
            }
        } catch let fetchError {
            print("Failed to fetch and create budget \(fetchError)")
        }
    }
    
    func createBudget(period: BudgetPeriod, for date: Date, existingBudgets: [Budget]) {
        
    }
}
