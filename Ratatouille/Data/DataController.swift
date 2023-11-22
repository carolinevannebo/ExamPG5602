//
//  DataController.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Ratatouille")
        
        // Do not persist to disk (this is not production)
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
            print(description)
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    static let shared = DataController()
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
//    init() {
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                print(error)
//            }
//            print(description)
//        }
//    }
}
