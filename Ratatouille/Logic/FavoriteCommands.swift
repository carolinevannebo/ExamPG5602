//
//  FavoriteCommands.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 25/11/2023.
//

import Foundation
import CoreData

class LoadFavoritesCommand: ICommand {
    typealias Input = Void
    typealias Output = [Meal]?

    func execute(input: Input) async -> Output {
        do {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                request.predicate = NSPredicate(format: "isArchived == false")
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            // TODO: this seems too simple, what are you forgetting?
            let favorites: [Meal] = try managedObjectContext.fetch(request)
            
            print("Loading \(favorites.count) favorites")
            return favorites
            
        } catch {
            print("Unexpected error in LoadFavoritesCommand: \(error)")
            return nil
        }
    }
}

class SaveFavoriteCommand: ICommand {
    typealias Input = MealModel
    typealias Output = Result<Meal, SaveFavoriteError>
    
    enum SaveFavoriteError: Error {
        case missingIdError(String)
        case noMatchingPredicateError
        case fetchingAttributeError
        case savingError
        case locatedInArchive(String)
    }
    
    func execute(input: Input) async -> Output {
        do {
            print("About to save favorite \(input.name) with ID: \(input.id)")
            
            if input.id.isEmpty {
                throw SaveFavoriteError.missingIdError("Meal ID is missing.")
            }
            
            let favoriteFetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
            favoriteFetchRequest.predicate = NSPredicate(format: "id == %@", input.id)
            
            let areaFetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
            areaFetchRequest.predicate = NSPredicate(format: "name == %@", input.area!.name)
            
            let categoryFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            categoryFetchRequest.predicate = NSPredicate(format: "id == %@", input.category!.id!)

            let managedObjectContext = DataController.shared.managedObjectContext
            var ingredientEntities: [Ingredient] = []
            
            for ingredient in input.ingredients! {
                // TODO: du kan bare lagre nye ingredienser? men det kan bli mange...
                
                let newIngredient = Ingredient(context: managedObjectContext)
                newIngredient.id = ingredient.id
                newIngredient.name = ingredient.name
                newIngredient.information = ingredient.information
                ingredientEntities.append(newIngredient)
                
            }
            
            var result: Result<Meal, SaveFavoriteError>?
            
            try await managedObjectContext.perform {
                
                let fetchedArea = try managedObjectContext.fetch(areaFetchRequest).first
                let fetchedCategory = try managedObjectContext.fetch(categoryFetchRequest).first
                
                if let fetchedFavorite = try managedObjectContext.fetch(favoriteFetchRequest).first {
                    
                    if fetchedFavorite.isArchived {
                        print("Meal is in archives.")
                        result = .failure(.locatedInArchive("Cannot perform action"))
                    } else {
                        print("Favorite meal is already saved: \(fetchedFavorite.name)")
                        result = .success(fetchedFavorite)
                    }
                } else {
                    let newFavorite = Meal(context: managedObjectContext)
                    newFavorite.id = input.id
                    newFavorite.name = input.name
                    newFavorite.image = input.image
                    newFavorite.instructions = input.instructions
                    newFavorite.area = fetchedArea
                    newFavorite.category = fetchedCategory
                    newFavorite.ingredients = NSSet(array: ingredientEntities)
                    newFavorite.isArchived = false
                    
                    result = .success(newFavorite)
                }
            }
            
            print("Saving favorite...")
            DataController.shared.saveContext()
            
            return result ?? .failure(.savingError)
        } catch {
            print("Unexpected error in SaveFavoriteCommand: \(error)")
            return .failure(.savingError)
        }
    }
}
