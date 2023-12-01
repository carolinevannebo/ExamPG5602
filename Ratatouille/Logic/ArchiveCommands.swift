//
//  ArchiveCommands.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 25/11/2023.
//

import Foundation
import CoreData

class LoadArchivesCommand: ICommand {
    typealias Input = Void
    typealias Output = [Meal]?

    func execute(input: Void) async -> Output {
        do {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                request.predicate = NSPredicate(format: "isArchived == true")
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            // TODO: this seems too simple, what are you forgetting?
            let archives: [Meal] = try managedObjectContext.fetch(request)
            
            print("Loading \(archives.count) meals from archive")
            return archives
            
        } catch {
            print("Unexpected error in LoadArchivesCommand: \(error)")
            return nil
        }
    }
}

class RestoreMealCommand: ICommand {
    typealias Input = Meal
    typealias Output = Result<Meal, RestoreMealError>
    
    enum RestoreMealError: Error {
        case missingIdError(String)
        case restoreError
        case fetchingMealError
        case mealNotArchivedError
    }
    
    func execute(input: Input) async -> Output {
        do {
            // Check for id
            if input.id.isEmpty {
                throw RestoreMealError.missingIdError("Meal ID is missing.")
            }
            
            // Fetch meal
            let mealRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
                mealRequest.predicate = NSPredicate(format: "id == %@", input.id)
                    
            // Variables for restoration
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Result<Meal, RestoreMealError>?
            
            // Perform restoration
            try await managedObjectContext.perform {
                if let fetchedMeal = try managedObjectContext.fetch(mealRequest).first {
                    // Check that meal is in archives
                    let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                        archiveRequest.predicate = NSPredicate(format: "meals CONTAINS %@", fetchedMeal)
                    
                    if let archive = try managedObjectContext.fetch(archiveRequest).first {
                        archive.removeFromMeals(fetchedMeal) // Remove meal from archive
                        
                        // Meal is still saved, but now marked as not archived. Meaning it will reappear in favorites
                        fetchedMeal.isArchived = false
                        result = .success(fetchedMeal)
                    } else {
                        result = .failure(.mealNotArchivedError)
                    }
                } else {
                    result = .failure(.fetchingMealError)
                }
            }
            
            // Save the context after restoration
            print("Restoring meal...")
            DataController.shared.saveContext()
                    
            return result ?? .failure(.restoreError)
        } catch {
            print("Unexpected error in RestoreMealCommand: \(error)")
            return .failure(.restoreError)
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
    
    func execute(input: Input) async -> Output {
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
            print("Unexpected error in DeleteMealCommand: \(error)")
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
        case fetchingMealError
    }
    
    func execute(input: Input) async -> Output {
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
                } else {
                    result = .failure(.fetchingMealError)
                }
            }
            
            print("Archiving meal...")
            DataController.shared.saveContext()
            
            return result ?? .failure(.archivingError)
        } catch {
            print("Unexpected error in ArchiveMealCommand: \(error)")
            return .failure(.archivingError)
        }
    }
}
