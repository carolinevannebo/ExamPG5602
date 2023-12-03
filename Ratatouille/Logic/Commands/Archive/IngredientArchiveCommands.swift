//
//  IngredientArchiveCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import CoreData

enum IngredientArchiveError: Error, LocalizedError {
    case missingIdError(String?)
    case unauthorizedError
    case fetchingIngredientError
    case ingredientNotArchivedError
    case archivingError
    case restoreError
    case deleteError
    
    var errorDescription: String? {
        switch self {
        case .missingIdError:
            return NSLocalizedString("Ugyldig id.", comment: "")
        case .unauthorizedError:
            return NSLocalizedString("Du kan kun arkivere dine egne ingredienser.", comment: "")
        case .fetchingIngredientError:
            return NSLocalizedString("Fikk ikke tak i ingrediens.", comment: "")
        case .ingredientNotArchivedError:
            return NSLocalizedString("Ingrediens ligger ikke i arkiv.", comment: "")
        case .archivingError:
            return NSLocalizedString("Kunne ikke arkivere ingrediens.", comment: "")
        case .restoreError:
            return NSLocalizedString("Kunne ikke gjenopprette ingrediens.", comment: "")
        case .deleteError:
            return NSLocalizedString("Kunne ikke slette ingrediens.", comment: "")
        }
    }
}

class LoadIngredientsFromArchivesCommand: ICommand {
    typealias Input = Void
    typealias Output = [Ingredient]?
    
    func execute(input: Input) async -> Output {
        do {
            let managedObjectContext = DataController.shared.managedObjectContext
            
            let request: NSFetchRequest<Archive> = Archive.fetchRequest()
            let archives = try managedObjectContext.fetch(request)
            
            let ingredients = archives.compactMap { $0.ingredients as? Set<Ingredient> }.flatMap { $0 }
            
            return ingredients
        } catch {
            print("Unexpected error in LoadIngredientsFromArchivesCommand: \(error)")
            return nil
        }
    }
}

class ArchiveIngredientCommand: ICommand {
    typealias Input = Ingredient
    typealias Output = Result<Archive, IngredientArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            // Check for id
            if input.id == nil {
                throw IngredientArchiveError.missingIdError("Ingredient ID is missing.")
            }
            
            // Only allow user to archive ingredients they have created
            for i in 0..<608 {
                if input.id == String(i+1) {
                    throw IngredientArchiveError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedIngredient = try managedObjectContext.fetch(request).first {
                    
                    // check archive
                    let request: NSFetchRequest<Archive> = Archive.fetchRequest()
                    request.predicate = NSPredicate(format: "ingredients CONTAINS %@", fetchedIngredient)
                    
                    if let fetchedArchive = try managedObjectContext.fetch(request).first {
                        // Ingredient is already archived
                        result = .success(fetchedArchive)
                    } else {
                        // If no ingredients has been archived yet, create entity
                        let newArchive = Archive(context: managedObjectContext)
                        newArchive.ingredients = NSSet(object: fetchedIngredient)
                        
                        result = .success(newArchive)
                    }
                } else {
                    result = .failure(.fetchingIngredientError)
                }
            }
            
            DataController.shared.saveContext()
            
            return result ?? .failure(.archivingError)
            
        } catch {
            print("Unexpected error in ArchiveIngredientCommand: \(error)")
            return .failure(error as! IngredientArchiveError)
        }
    }
}

class RestoreIngredientCommand: ICommand {
    typealias Input = Ingredient
    typealias Output = Result<Ingredient, IngredientArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            // Check for id
            if input.id == nil {
                throw IngredientArchiveError.missingIdError("Ingredient ID is missing.")
            }
            
            // Fetch category
            let ingredientRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
            ingredientRequest.predicate = NSPredicate(format: "id == %@", input.id!)
            
            // Variables for restoration
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Output?
            
            // Perform restoration
            try await managedObjectContext.perform {
                if let fetchedIngredient = try managedObjectContext.fetch(ingredientRequest).first {
                    
                    // Check that category is in archives
                    let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                        archiveRequest.predicate = NSPredicate(format: "ingredients CONTAINS %@", fetchedIngredient)
                    
                    if let archive = try managedObjectContext.fetch(archiveRequest).first {
                        archive.removeFromIngredients(fetchedIngredient) // Remove category from archive
                        result = .success(fetchedIngredient)
                    } else {
                        result = .failure(.ingredientNotArchivedError)
                    }
                } else {
                    result = .failure(.fetchingIngredientError)
                }
            }
            
            // Save the context after restoration
            print("Restoring ingredient...")
            DataController.shared.saveContext()
                    
            return result ?? .failure(.restoreError)
            
        } catch {
            print("Unexpected error in RestoreIngredientCommand: \(error)")
            return .failure(error as! IngredientArchiveError)
        }
    }
}

class DeleteIngredientCommand: ICommand {
    typealias Input = Ingredient
    typealias Output = Result<Void, IngredientArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw IngredientArchiveError.missingIdError("Ingredient ID is missing.")
            }
            
            // Users should not be able to archive certain ingredients in the first place, so this is better safe than sorry
            for i in 0..<608 {
                if input.id == String(i+1) {
                    throw IngredientArchiveError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            try await managedObjectContext.perform {
                if let fetchedIngredient = try managedObjectContext.fetch(request).first {
                    
                    let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                    archiveRequest.predicate = NSPredicate(format: "ingredients CONTAINS %@", fetchedIngredient)
                    
                    if let archivedIngredient = try managedObjectContext.fetch(archiveRequest).first {
                        archivedIngredient.removeFromIngredients(fetchedIngredient)
                        managedObjectContext.delete(fetchedIngredient)
                    } else {
                        throw IngredientArchiveError.ingredientNotArchivedError
                    }
                } else {
                    throw IngredientArchiveError.fetchingIngredientError
                }
            }
            
            DataController.shared.saveContext()
            return .success(())
        } catch {
            print("Unexpected error in DeleteIngredientCommand: \(error)")
            return .failure(error as! IngredientArchiveError)
        }
    }
}
