//
//  DataController.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 13/11/2023.
//

import Foundation
import CoreData
import SwiftUI

class DataController: ObservableObject {
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Ratatouille")
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        container.persistentStoreDescriptions.first!.url = documentsURL.appendingPathComponent("Ratatouille.sqlite")
        
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
