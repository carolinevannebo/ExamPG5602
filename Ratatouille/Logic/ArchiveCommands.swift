//
//  ArchiveCommands.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 25/11/2023.
//

import Foundation
import CoreData

class LoadMealsFromArchivesCommand: ICommand {
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
            print("Unexpected error in LoadMealsFromArchivesCommand: \(error)")
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
                        managedObjectContext.delete(fetchedMeal)
                    }
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
    typealias Input = MealRepresentable // Changed input from Meal to MealRepresentable to archive from different views
    typealias Output = Result<Archive, ArchiveMealError>
    
    enum ArchiveMealError: Error {
        case missingIdError(String)
        case archivingError
        case fetchingMealError
    }
    
    func execute(input: any Input) async -> Output {
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

class LoadCategoriesFromArchivesCommand: ICommand {
    typealias Input = Void
    typealias Output = [Category]?
    
    func execute(input: Input) async -> Output {
        do {
            let managedObjectContext = DataController.shared.managedObjectContext
            
            let request: NSFetchRequest<Archive> = Archive.fetchRequest()
            let archives = try managedObjectContext.fetch(request)
            
            let categories = archives.compactMap { $0.categories as? Set<Category> }.flatMap { $0 }
            
            return categories
        } catch {
            print("Unexpected error in LoadCategoriesFromArchivesCommand: \(error)")
            return nil
        }
    }
}

class DeleteCategoryCommand: ICommand {
    typealias Input = Category
    typealias Output = Result<Void, DeleteCategoryError>
    
    enum DeleteCategoryError: Error {
        case missingIdError(String)
        case deleteError
        case unauthorizedError
    }
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw DeleteCategoryError.missingIdError("Category ID is missing.")
            }
            
            // Only allow user to delete categories they have created
            for i in 0..<14 {
                if input.id == String(i+1) {
                    throw DeleteCategoryError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            try await managedObjectContext.perform {
                if let fetchedCategory = try managedObjectContext.fetch(request).first {
                    
                    let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                    archiveRequest.predicate = NSPredicate(format: "categories CONTAINS %@", fetchedCategory)
                    
                    if let archivedCategory = try managedObjectContext.fetch(archiveRequest).first {
                        archivedCategory.removeFromCategories(fetchedCategory)
                        managedObjectContext.delete(fetchedCategory)
                    }
                }
            }
            
            DataController.shared.saveContext()
            return .success(())
        } catch {
            print("Unexpected error in DeleteCategoryCommand: \(error)")
            return .failure(.deleteError)
        }
    }
}



class ArchiveCategoryCommand: ICommand {
    typealias Input = Category
    typealias Output = Result<Archive, ArchiveCategoryError>
    
    enum ArchiveCategoryError: Error {
        case missingIdError(String)
        case archivingError
        case fetchingCategoryError
        case unauthorizedError
    }
    
    func execute(input: Input) async -> Output {
        do {
            // Check for id
            if input.id == nil {
                throw ArchiveCategoryError.missingIdError("Category ID is missing.")
            }
            
            // Only allow user to delete categories they have created
            for i in 0..<14 {
                if input.id == String(i+1) {
                    throw ArchiveCategoryError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedCategory = try managedObjectContext.fetch(request).first {
                    
                    // check archive
                    let request: NSFetchRequest<Archive> = Archive.fetchRequest()
                    request.predicate = NSPredicate(format: "categories CONTAINS %@", fetchedCategory)
                    
                    if let fetchedArchive = try managedObjectContext.fetch(request).first {
                        // Category is already archived
                        result = .success(fetchedArchive)
                    } else {
                        // If no categories has been archived yet, create entity
                        let newArchive = Archive(context: managedObjectContext)
                        newArchive.categories = NSSet(object: fetchedCategory)
                        
                        result = .success(newArchive)
                    }
                } else {
                    result = .failure(.fetchingCategoryError)
                }
            }
            
            DataController.shared.saveContext()
            
            return result ?? .failure(.archivingError)
            
        } catch {
            print("Unexpected error in ArchiveCategoryCommand: \(error)")
            return .failure(.archivingError)
        }
    }
}
