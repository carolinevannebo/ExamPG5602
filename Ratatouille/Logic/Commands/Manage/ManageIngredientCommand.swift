//
//  ManageIngredientCommand.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import CoreData

enum ManageIngredientError: Error {
    case missingIdError(String)
    case unauthorizedError
    case duplicateError
    case fetchError
    case updateError
    case savingError
}

class AddNewIngredientCommand: ICommand {
    typealias Input = IngredientModel
    typealias Output = Result<Ingredient, ManageIngredientError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw ManageIngredientError.missingIdError("Ingredient ID is missing.")
            }
            
            let request: NSFetchRequest<Area> = Area.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedIngredient = try managedObjectContext.fetch(request).first {
                    
                    print("Ingredient with name \(fetchedIngredient.name) is already saved")
                    result = .failure(.duplicateError)
                } else {
                    let newIngredient = Ingredient(context: managedObjectContext)
                    newIngredient.id = input.id
                    newIngredient.name = input.name
                    newIngredient.information = input.information
                    
                    result = .success(newIngredient)
                }
            }
            
            DataController.shared.saveContext()
            return result ?? .failure(.savingError)
            
        } catch {
            print("Unexpected error in AddNewIngredientCommand: \(error)")
            return .failure(.savingError)
        }
    }
}

class UpdateIngredientCommand: ICommand {
    typealias Input = Ingredient
    typealias Output = Result<Ingredient, ManageIngredientError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw ManageIngredientError.missingIdError("Ingredient ID is missing.")
            }
            
            // Only allow user to update ingredients they have created
            for i in 0..<608 {
                if input.id == String(i+1) {
                    throw ManageIngredientError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedIngredient = try managedObjectContext.fetch(request).first {
                    fetchedIngredient.name = input.name
                    fetchedIngredient.information = input.information
                    
                    result = .success(fetchedIngredient)
                } else {
                    result = .failure(.fetchError)
                }
            }
            
            DataController.shared.saveContext()
            return result ?? .failure(.updateError)
        } catch {
            print("Unexpected error in UpdateIngredientCommand: \(error)")
            return .failure(.updateError)
        }
    }
}

