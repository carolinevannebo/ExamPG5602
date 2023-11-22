//
//  DataController.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//

import Foundation
import CoreData
import SwiftUI

class DataController: ObservableObject {
//    private var _managedObjectContext: NSManagedObjectContext?
    
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
    
//    var managedObjectContext: NSManagedObjectContext {
//        if let context = _managedObjectContext {
//            return context
//        }
//
//        // Attempt to retrieve the context from the environment
//        if let context = Environment(\.managedObjectContext) as? NSManagedObjectContext {
//            _managedObjectContext = context
//            return context
//        }
//
//        fatalError("Managed object context not set in the environment.")
//    }
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    static let shared = DataController()
    
//    init() {
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                print(error)
//            }
//            print(description)
//        }
//    }
}
