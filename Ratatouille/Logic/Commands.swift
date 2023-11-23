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

class InitCD: ICommand {
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

class SearchMeals: ICommand {
    typealias Input = String
    typealias Output = [MealModel]?
    
    func execute(input: String) async -> Output {
        do {
            let result = await APIClient.getMeals(input: input)
            
            switch result {
                
            case .success(let meals):
                print("Got \(meals.count) meals")
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

class SearchRandom: ICommand {
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

class SearchIngredients: ICommand {
    typealias Input = String
    typealias Output = [IngredientModel]?
    
    func execute(input: String) async -> Output {
        do {
            let result = await APIClient.getIngredients(input: input)
            
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

class SearchAreas: ICommand {
    typealias Input = String
    typealias Output = [AreaModel]?
    
    func execute(input: String) async -> Output {
        do {
            let result = await APIClient.getAreas(input: input)
            
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

class SearchCategories: ICommand {
    typealias Input = String
    typealias Output = [CategoryModel]?
    
    func execute(input: String) async -> Output {
        do {
            let result = await APIClient.getCategories(input: input)
            
            switch result {
                case .success(let categories):
                    print("Got \(categories.count) meals")
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

//class LoadFavorites: ICommand {
//    typealias Input = Void
//    typealias Output = [MealModel]?
//
//    func execute(input: Void) async -> [MealModel]? {
//        do {
//
//        } catch {
//            print("Unexpected error: \(error)")
//            return nil
//        }
//    }
//}

class SaveFavorite: ICommand {
    typealias Input = MealModel
    typealias Output = Result<Meal, SaveFavoriteError>
    
    enum SaveFavoriteError: Error {
        case unMatchedId
        case noMatchingPredicateError
        case fetchingAttributeError
        case fetchingEntityError
        case savingError
    }
    
    func execute(input: MealModel) async -> Result<Meal, SaveFavoriteError> {
        do {
            print("About to save favorite \(input.name) with ID: \(input.id)")
            
            let favoriteFetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
            favoriteFetchRequest.predicate = NSPredicate(format: "id == %@", input.id)
            
            let areaFetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
            areaFetchRequest.predicate = NSPredicate(format: "name == %@", input.area!.name)
            
            let categoryFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            categoryFetchRequest.predicate = NSPredicate(format: "name == %@", input.category!.name)
            
            var ingredientFetchRequests: [NSFetchRequest<Ingredient>] = []
            
            for ingredient in input.ingredients {
                let ingredientFetchRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
                
                let commaIndex = (ingredient.name?.firstIndex(of: ",") ?? ingredient.name?.endIndex)!
                let substringValue = ingredient.name?[..<commaIndex]
                
                ingredientFetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "name", substringValue! as CVarArg)
                ingredientFetchRequests.append(ingredientFetchRequest)
            }
            
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Result<Meal, SaveFavoriteError>?
            
            try await managedObjectContext.perform {
                
                let fetchedArea = try managedObjectContext.fetch(areaFetchRequest).first
                print("Got meal's area: \(fetchedArea?.name ?? "unknown")")
                let fetchedCategory = try managedObjectContext.fetch(categoryFetchRequest).first
                print("Got meal's category: \(fetchedCategory?.name ?? "unknown")")
                
                var fetchedIngredients: [Ingredient] = []
                
                for request in ingredientFetchRequests {
                    let fetchedIngredient = try managedObjectContext.fetch(request)
                    fetchedIngredients.append(contentsOf: fetchedIngredient)
                }
                print("Got \(fetchedIngredients.count) ingredients in meal")
                
                if let fetchedFavorite = try managedObjectContext.fetch(favoriteFetchRequest).first {
                    fetchedFavorite.name = input.name
                    fetchedFavorite.image = input.image
                    fetchedFavorite.instructions = input.instructions
                    fetchedFavorite.area = fetchedArea
                    fetchedFavorite.category = fetchedCategory
                    fetchedFavorite.ingredients = NSSet(array: fetchedIngredients)
                    
                    print("Favorite meal is already saved, updating: \(fetchedFavorite.name!)")
                    result = .success(fetchedFavorite)
                } else {
                    let newFavorite = Meal(context: managedObjectContext)
                    newFavorite.id = input.id
                    newFavorite.name = input.name
                    newFavorite.image = input.image
                    newFavorite.instructions = input.instructions
                    newFavorite.area = fetchedArea
                    newFavorite.category = fetchedCategory
                    newFavorite.ingredients = NSSet(array: fetchedIngredients)
                    
                    print("New favorite created: \(newFavorite.name ?? "unknown name for some reason")")
                    result = .success(newFavorite)
                }
            }
            
            print("Saving favorite...")
            DataController.shared.saveContext()
            return result ?? .failure(.fetchingEntityError)
        } catch {
            print("Unexpected error: \(error)")
            return .failure(.savingError)
        }
    }
}
