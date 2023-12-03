//
//  CategoryArchiveCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import CoreData

enum CategoryArchiveError: Error {
    case missingIdError(String)
    case unauthorizedError
    case fetchingCategoryError
    case categoryNotArchivedError
    case archivingError
    case restoreError
    case deleteError
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

class ArchiveCategoryCommand: ICommand {
    typealias Input = Category
    typealias Output = Result<Archive, CategoryArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            // Check for id
            if input.id == nil {
                throw CategoryArchiveError.missingIdError("Category ID is missing.")
            }
            
            // Only allow user to archive categories they have created
            for i in 0..<14 {
                if input.id == String(i+1) {
                    throw CategoryArchiveError.unauthorizedError
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

class RestoreCategoryCommand: ICommand {
    typealias Input = Category
    typealias Output = Result<Category, CategoryArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            // Check for id
            if input.id == nil {
                throw CategoryArchiveError.missingIdError("Category ID is missing.")
            }
            
            // Fetch category
            let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "id == %@", input.id!)
            
            // Variables for restoration
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Output?
            
            // Perform restoration
            try await managedObjectContext.perform {
                if let fetchedCategory = try managedObjectContext.fetch(categoryRequest).first {
                    
                    // Check that category is in archives
                    let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                        archiveRequest.predicate = NSPredicate(format: "categories CONTAINS %@", fetchedCategory)
                    
                    if let archive = try managedObjectContext.fetch(archiveRequest).first {
                        archive.removeFromCategories(fetchedCategory) // Remove category from archive
                        result = .success(fetchedCategory)
                    } else {
                        result = .failure(.categoryNotArchivedError)
                    }
                } else {
                    result = .failure(.fetchingCategoryError)
                }
            }
            
            // Save the context after restoration
            print("Restoring category...")
            DataController.shared.saveContext()
                    
            return result ?? .failure(.restoreError)
            
        } catch {
            print("Unexpected error in RestoreCategoryCommand: \(error)")
            return .failure(.restoreError)
        }
    }
}

class DeleteCategoryCommand: ICommand {
    typealias Input = Category
    typealias Output = Result<Void, CategoryArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw CategoryArchiveError.missingIdError("Category ID is missing.")
            }
            
            // Users should not be able to archive certain categories in the first place, so this is better safe than sorry
            for i in 0..<14 {
                if input.id == String(i+1) {
                    throw CategoryArchiveError.unauthorizedError
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

