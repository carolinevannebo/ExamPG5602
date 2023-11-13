//
//  DataController.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Ratatouille")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print(error)
            }
            print(description)
        }
    }
    
    static let shared = DataController()
}
