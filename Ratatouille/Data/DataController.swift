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
    
}
