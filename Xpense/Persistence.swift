//
//  Persistence.swift
//  test
//
//  Created by Teddy Santya on 11/10/20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    let listener: RemoteObjectListener
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Financial")
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        listener = RemoteObjectListener(container: container)
    }
    
    func validateCategoriesSeed() {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<CategoryModel>(entityName: "Category")
        
        do {
            let categories = try context.fetch(fetchRequest)
            if categories.count == 0 {
                seedCategories()
            }
        } catch let fetchError {
            print("Failed to fetch PaymentMethods \(fetchError)")
        }
    }
    
    
}

class RemoteObjectListener {
    var container: NSPersistentCloudKitContainer
    
    init(container: NSPersistentCloudKitContainer) {
        self.container = container
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifyReceiveRemoteObjects), name: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator)
    }
    
    @objc
    func notifyReceiveRemoteObjects() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("RemoteObjectReceived"), object: nil)
        }
    }
}
