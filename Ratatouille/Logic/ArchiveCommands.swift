//
//  ArchiveCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 25/11/2023.
//

import Foundation
import CoreData

class LoadArchivesCommand: ICommand {
    typealias Input = Void
    typealias Output = [Meal]?

    func execute(input: Void) async -> [Meal]? {
        do {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                request.predicate = NSPredicate(format: "isArchived == true")
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            // TODO: this seems too simple, what are you forgetting?
            let archives: [Meal] = try managedObjectContext.fetch(request)
            
            print("Loading \(archives.count) meals from archive")
            return archives
            
        } catch {
            print("Unexpected error: \(error)")
            return nil
        }
    }
}

class DeleteMealCommand: ICommand {
    typealias Input = Meal
    typealias Output = Result<Void, DeleteMealError>
    
    enum DeleteMealError: Error {
        case missingIdError(String)
        case deleteError
    }
    
    func execute(input: Meal) async -> Result<Void, DeleteMealError> {
        do {
            // Check for id
            if input.id.isEmpty {
                throw DeleteMealError.missingIdError("Meal ID is missing.")
            }
                    
            // Fetch meal
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", input.id)
                    
            // Variables for deletion
            let managedObjectContext = DataController.shared.managedObjectContext
                    
            // Perform deletion
            try await managedObjectContext.perform {
                if let fetchedMeal = try managedObjectContext.fetch(request).first {
                    // Check for archive
                    let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                        archiveRequest.predicate = NSPredicate(format: "meals CONTAINS %@", fetchedMeal)
                            
                    if let archivedMeal = try managedObjectContext.fetch(archiveRequest).first {
                            archivedMeal.removeFromMeals(fetchedMeal)
                    }
                            
                    managedObjectContext.delete(fetchedMeal)
                }
            }
                    
            // Save the context after deletion
            DataController.shared.saveContext()
                    
            return .success(())
        } catch {
            print("Unexpected error: \(error)")
            return .failure(.deleteError)
        }
    }
}

class ArchiveMealCommand: ICommand {
    typealias Input = Meal
    typealias Output = Result<Archive, ArchiveMealError>
    
    enum ArchiveMealError: Error {
        case missingIdError(String)
        case archivingError
    }
    
    func execute(input: Meal) async -> Result<Archive, ArchiveMealError> {
        do {
            // Check for id
            if input.id.isEmpty {
                throw ArchiveMealError.missingIdError("Meal ID is missing.")
            }
            
            // Fetch meal
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id)
            
            // Variables for moving from favorites to archive
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Result<Archive, ArchiveMealError>?
            
            // Perform move
            try await managedObjectContext.perform {
                if let fetchedMeal = try managedObjectContext.fetch(request).first {
                    fetchedMeal.isArchived = true
                    
                    // Check for archive
                    let request: NSFetchRequest<Archive> = Archive.fetchRequest()
                    request.predicate = NSPredicate(format: "meals CONTAINS %@", fetchedMeal)
                    
                    if let fetchedArchive = try managedObjectContext.fetch(request).first {
                        // Meal is already archived
                        result = .success(fetchedArchive)
                    } else {
                        // If no favorites has been archived yet, create entity
                        let newArchive = Archive(context: managedObjectContext)
                        newArchive.meals = NSSet(object: fetchedMeal)
                        
                        result = .success(newArchive)
                    }
                }
            }
            
            print("Archiving meal...")
            DataController.shared.saveContext()
            
            return result ?? .failure(.archivingError)
        } catch {
            print("Unexpected error: \(error)")
            return .failure(.archivingError)
        }
    }
}
