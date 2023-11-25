//
//  Commands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import Foundation
import CoreData

public protocol ICommand {
    associatedtype Input
    associatedtype Output
    
    func execute(input: Input) async -> Output
}

class InitCDCommand: ICommand {
    typealias Input = NSManagedObjectContext
    typealias Output = Void
    
    func execute(input: NSManagedObjectContext) async -> Void {
        Task {
            await APIClient.saveCategories(managedObjectContext: input)
            await APIClient.saveAreas(managedObjectContext: input)
            await APIClient.saveIngredients(managedObjectContext: input)
        }
    }
}

class SearchMealsCommand: ICommand {
    typealias Input = String
    typealias Output = [MealModel]?
    
    func execute(input: String) async -> Output {
        do {
            let result = await APIClient.getMeals(input: input)
            
            switch result {
                
            case .success(var meals):
                print("Got \(meals.count) meals, loading isFavorite attribute...")
                
                let managedObjectContext = DataController.shared.managedObjectContext
                
                meals = try meals.map { meal -> MealModel in
                    let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                        request.predicate = NSPredicate(format: "id == %@", meal.id)
                    
                    if let match: Meal = try managedObjectContext.fetch(request).first {
                        var updatedMeal = meal
                            updatedMeal.isFavorite = true
                        
                        print("updated meal from search is favorite")
                        return updatedMeal
                    } else {
                        return meal
                    }
                }
                
                return meals
                
            case .failure(let error):
                switch error {
                    case .badInput:
                        print("No results for the provided input")
                        throw error
                    case .unMatchedId:
                        print("No id matched search")
                        throw error
                    default:
                        print("Unexpected error: \(error)")
                        throw error
                }
            }
        } catch {
            print("Error: \(error)") // TODO: feilhåndtering med meldinger til UI
            return nil
        }
    }
}

class SearchRandomCommand: ICommand {
    typealias Input = Void
    typealias Output = MealModel?

    func execute(input: Void) async -> Output {
        do {
            let result = await APIClient.getRandomMeal()

            switch result {
                case .success(let meal):
                print("Got meal: \(meal.name )")
                    return meal
                case .failure(let error):
                    throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            return nil
        }
    }
}

class ListIngredientsCommand: ICommand {
    typealias Input = String
    typealias Output = [IngredientModel]?

    func execute(input: String) async -> Output {
        do {
            let result = await APIClient.getIngredients()

            switch result {
                case .success(let ingredients):
                    print("Got \(ingredients.count) meals")
                    return ingredients
                case .failure(let error):
                    throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            return nil
        }
    }
}

class ListAreasCommand: ICommand {
    typealias Input = String
    typealias Output = [AreaModel]?

    func execute(input: String) async -> Output {
        do {
            let result = await APIClient.getAreas()

            switch result {
                case .success(let areas):
                    print("Got \(areas.count) meals")
                    return areas
                case .failure(let error):
                    throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            return nil
        }
    }
}

// TODO: this filter logic is slow, fix it
class FilterByCategoriesCommand: ICommand {
    typealias Input = String
    typealias Output = [MealModel]?

    func execute(input: String) async -> Output {
        do {
            let result = await APIClient.filterMealsByCategory(input: input)

            switch result {
                case .success(let meals):
                    print("Got \(meals.count) meals, loading missing information...")
                
                var completeMeals: [MealModel] = []
                
                for meal in meals {
                    let newResult = await APIClient.getMeals(input: meal.id)
                    
                    switch newResult {
                    case .success(let idMeals):
                        for id in idMeals {
                            completeMeals.append(id)
                        }
                    case .failure(let error):
                        throw error
                    }
                }
                return completeMeals
//                    return meals
                case .failure(let error):
                    throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            return nil
        }
    }
}

class LoadCategoriesCommand: ICommand {
    typealias Input = Void
    typealias Output = [CategoryModel]?
    
    func execute(input: Void) async -> Output {
        do {
            let result = await APIClient.getCategories()
            
            switch result {
            case .success(let categories):
                print("Got \(categories.count) categories")
                return categories
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            return nil
        }
    }
}

class LoadFavoritesCommand: ICommand {
    typealias Input = Void
    typealias Output = [Meal]?

    func execute(input: Void) async -> [Meal]? {
        do {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                request.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: false))
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            // TODO: this seems too simple, what are you forgetting?
            let favorites: [Meal] = try managedObjectContext.fetch(request)
            
            print("Loading \(favorites.count) favorites")
            return favorites
            
        } catch {
            print("Unexpected error: \(error)")
            return nil
        }
    }
}

class LoadArchivesCommand: ICommand {
    typealias Input = Void
    typealias Output = [Meal]?

    func execute(input: Void) async -> [Meal]? {
        do {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                request.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: true))
            
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

class ArchiveMealCommand: ICommand {
    typealias Input = Meal
    typealias Output = Result<Meal, ArchiveMealError>
    
    enum ArchiveMealError: Error {
        case missingIdError(String)
        case archivingError
    }
    
    func execute(input: Meal) async -> Result<Meal, ArchiveMealError> {
        do {
            if input.id.isEmpty {
                throw ArchiveMealError.missingIdError("Meal ID is missing.")
            }
            
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Result<Meal, ArchiveMealError>?
            
            try await managedObjectContext.perform {
                if let fetchedMeal = try managedObjectContext.fetch(request).first {
                    fetchedMeal.isArchived = true
                    
                    result = .success(fetchedMeal)
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

class SaveFavoriteCommand: ICommand {
    typealias Input = MealModel
    typealias Output = Result<Meal, SaveFavoriteError>
    
    enum SaveFavoriteError: Error {
        case missingIdError(String)
        case noMatchingPredicateError
        case fetchingAttributeError
        case savingError
    }
    
    func execute(input: MealModel) async -> Result<Meal, SaveFavoriteError> {
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
            
//            var ingredientFetchRequests: [NSFetchRequest<Ingredient>] = []
            let managedObjectContext = DataController.shared.managedObjectContext
            var ingredientEntities: [Ingredient] = []
            
            for ingredient in input.ingredients! {
                // TODO: du kan bare lagre nye ingredienser? men det kan bli mange...
                
                let newIngredient = Ingredient(context: managedObjectContext)
                newIngredient.id = ingredient.id
                newIngredient.name = ingredient.name
                newIngredient.information = ingredient.information
                ingredientEntities.append(newIngredient)
                
//                let ingredientFetchRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
////                ingredientFetchRequest.predicate = NSPredicate(format: "id == %@", ingredient.id!) // id er ikke lik lenger
//
//                let commaIndex = (ingredient.name?.firstIndex(of: ",") ?? ingredient.name?.endIndex)!
//                let substringValue = ingredient.name?[..<commaIndex]
//
//                ingredientFetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "name", substringValue! as CVarArg)
                
//                ingredientFetchRequests.append(ingredientFetchRequest)
            }
            
            var result: Result<Meal, SaveFavoriteError>?
            
            try await managedObjectContext.perform {
                
                let fetchedArea = try managedObjectContext.fetch(areaFetchRequest).first
                let fetchedCategory = try managedObjectContext.fetch(categoryFetchRequest).first
                
                if let fetchedFavorite = try managedObjectContext.fetch(favoriteFetchRequest).first {
                    print("Favorite meal is already saved: \(fetchedFavorite.name!)")
                    result = .success(fetchedFavorite)
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
                    
                    print("New favorite created: \(newFavorite.name ?? "unknown name for some reason")")
                    
                    print("This favorite has the following attributes: ")
                    print("id: \(newFavorite.id)")
                    print("image: \(newFavorite.image ?? "unknown image")")
                    print("area: \(newFavorite.area?.name ?? "unknown area")")
                    print("category name: \(newFavorite.category?.name ?? "unknown category name")")
                    print("category id: \(newFavorite.category?.id ?? "unknown category id")")
                    print("category image: \(newFavorite.category?.image ?? "unknown category image")")
                    print("category information: \(newFavorite.category?.information ?? "unknown category information")")
                    print("isArchived: \(newFavorite.isArchived)")
                    
                    result = .success(newFavorite)
//                    input.isFavorite = true
                }
            }
            
            print("Saving favorite...")
            DataController.shared.saveContext()
            
            return result ?? .failure(.savingError)
        } catch {
            print("Unexpected error: \(error)")
            return .failure(.savingError)
        }
    }
}
