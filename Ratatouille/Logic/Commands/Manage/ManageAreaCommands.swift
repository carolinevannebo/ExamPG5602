//
//  ManageAreaCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import CoreData

enum ManageAreaError: Error {
    case missingIdError(String)
    case unauthorizedError
    case duplicateError
    case fetchError
    case updateError
    case savingError
}

class AddNewAreaCommand: ICommand {
    typealias Input = AreaModel
    typealias Output = Result<Area, ManageAreaError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw ManageAreaError.missingIdError("Area ID is missing.")
            }
            
            let request: NSFetchRequest<Area> = Area.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedArea = try managedObjectContext.fetch(request).first {
                    
                    print("Area with name \(fetchedArea.name) is already saved")
                    result = .failure(.duplicateError)
                } else {
                    let newArea = Area(context: managedObjectContext)
                    newArea.id = input.id
                    newArea.name = input.name
                    
                    result = .success(newArea)
                }
            }
            
            DataController.shared.saveContext()
            return result ?? .failure(.savingError)
            
        } catch {
            print("Unexpected error in AddNewAreaCommand: \(error)")
            return .failure(.savingError)
        }
    }
}

class UpdateAreaCommand: ICommand {
    typealias Input = Area
    typealias Output = Result<Area, ManageAreaError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw ManageAreaError.missingIdError("Area ID is missing.")
            }
            
            // Only allow user to update areas they have created
            for i in 0..<28 {
                if input.id == String(i+1) {
                    throw ManageAreaError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Area> = Area.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedArea = try managedObjectContext.fetch(request).first {
                    fetchedArea.name = input.name
                    
                    result = .success(fetchedArea)
                } else {
                    result = .failure(.fetchError)
                }
            }
            
            DataController.shared.saveContext()
            return result ?? .failure(.updateError)
        } catch {
            print("Unexpected error in UpdateAreaCommand: \(error)")
            return .failure(.updateError)
        }
    }
}
