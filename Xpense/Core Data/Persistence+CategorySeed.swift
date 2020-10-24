//
//  Persistence+CategorySeed.swift
//  Xpense
//
//  Created by Teddy Santya on 24/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation
import SFSafeSymbols
import UIKit

private struct CategoryContainer {
    var name: String
    var type: CategoryType
    var symbolName: SFSymbol?
    var customTextIcon: String?
    var color: UIColor
    var lighterColor: UIColor {
        color.lighter()!
    }
}

extension PersistenceController {
    
    fileprivate struct Seeder {
        fileprivate lazy var categories: [CategoryContainer] = {
            [
                // expense
                CategoryContainer(name: "Food & Drinks", type: .expense, symbolName: nil, customTextIcon: "🍔", color: .systemRed),
                CategoryContainer(name: "Friends & Lover", type: .expense, symbolName: nil, customTextIcon: "❤️", color: .systemPink),
                CategoryContainer(name: "Health", type: .expense, symbolName: nil, customTextIcon: "🏥", color: .systemOrange),
                CategoryContainer(name: "Family", type: .expense, symbolName: nil, customTextIcon: "👨‍👨‍👧‍👦", color: .systemYellow),
                CategoryContainer(name: "Shopping", type: .expense, symbolName: nil, customTextIcon: "🛍", color: .systemPurple),
                CategoryContainer(name: "Entertainment", type: .expense, symbolName: nil, customTextIcon: "🍿", color: .link),
                CategoryContainer(name: "Travel", type: .expense, symbolName: nil, customTextIcon: "✈️", color: .systemBlue),
                CategoryContainer(name: "Transportation", type: .expense, symbolName: nil, customTextIcon: "🚘", color: .systemGreen),
                CategoryContainer(name: "Bills & Utilities", type: .expense, symbolName: nil, customTextIcon: "🧾", color: .systemGray),
                CategoryContainer(name: "Education", type: .expense, symbolName: nil, customTextIcon: "🎓", color: .systemFill),
                
                // income
                CategoryContainer(name: "Salary", type: .income, symbolName: nil, customTextIcon: "💵", color: .systemGreen),
                CategoryContainer(name: "Interest", type: .income, symbolName: nil, customTextIcon: "🏦", color: .link),
                CategoryContainer(name: "Gift", type: .income, symbolName: nil, customTextIcon: "🎁", color: .systemRed),
                CategoryContainer(name: "Selling", type: .income, symbolName: nil, customTextIcon: "💰", color: .systemOrange)
            ]
        }()
    }
    
    func seedCategories() {
        var seeder = Seeder()
        let seeds = seeder.categories
        let viewContext = container.viewContext
        
        for seed in seeds {
            let category = CategoryModel(context: viewContext)
            category.name = seed.name
            category.type = seed.type.rawValue
            category.symbolName = seed.symbolName?.rawValue
            category.text = seed.customTextIcon
            category.color = seed.color.encode()
            category.lighterColor = seed.lighterColor.encode()
            category.timeStamp = Date()
            
            do {
                try viewContext.save()
            } catch let createError {
                print("Failed to edit Category \(createError)")
            }
        }
    }
    
}
