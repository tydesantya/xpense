//
//  CoreDataManager.swift
//  Xpense
//
//  Created by Teddy Santya on 10/10/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct CoreDataManager {
    
    static let shared =  CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Financial")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Failed when loading stores \(error)")
            }
        }
        return container
    }()
    
    func createPaymentMethod(balance: DisplayCurrencyValue, type: PaymentMethodType, identifierNumber: String, name: String, color: UIColor) -> PaymentMethod? {
        let context = persistentContainer.viewContext
        let paymentMethod = PaymentMethod(context: context)
        paymentMethod.name = name
        paymentMethod.balance = balance
        paymentMethod.identifierNumber = identifierNumber
        paymentMethod.type = type.rawValue
        paymentMethod.color = color.encode()
        
        do {
            try context.save()
            return paymentMethod
        } catch let createError {
            print("Failed to create PaymentMethod \(createError)")
        }
        
        return nil
    }
    
    func fetchPaymentMethods() -> [PaymentMethod]? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<PaymentMethod>(entityName: "PaymentMethod")
        
        do {
            let paymentMethods = try context.fetch(fetchRequest)
            return paymentMethods
        } catch let fetchError {
            print("Failed to fetch PaymentMethods \(fetchError)")
        }
        
        return nil
    }
    
    func deletePaymentMethods() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PaymentMethod")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let context = persistentContainer.viewContext
        
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("Failed to delete PaymentMethods \(error)")
        }
    }
}

@objc(DisplayCurrencyTransformer)
class DisplayCurrencyTransformer: NSSecureUnarchiveFromDataTransformer {
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return [DisplayCurrencyValue.self]
    }
    
}

extension UIColor {
    
    class func color(data:Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
    
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
