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
                
                // testing
                for meal in meals {
                    print("meal has category entity with name \(meal.category?.name ?? "unknown") and id \(meal.category?.id ?? "unknown")")
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

//class SearchIngredients: ICommand {
//    typealias Input = String
//    typealias Output = [IngredientModel]?
//
//    func execute(input: String) async -> Output {
//        do {
//            let result = await APIClient.getIngredients(input: input)
//
//            switch result {
//                case .success(let ingredients):
//                    print("Got \(ingredients.count) meals")
//                    return ingredients
//                case .failure(let error):
//                    throw error
//            }
//        } catch {
//            print("Unexpected error: \(error)")
//            return nil
//        }
//    }
//}
//
//class SearchAreas: ICommand {
//    typealias Input = String
//    typealias Output = [AreaModel]?
//
//    func execute(input: String) async -> Output {
//        do {
//            let result = await APIClient.getAreas(input: input)
//
//            switch result {
//                case .success(let areas):
//                    print("Got \(areas.count) meals")
//                    return areas
//                case .failure(let error):
//                    throw error
//            }
//        } catch {
//            print("Unexpected error: \(error)")
//            return nil
//        }
//    }
//}

class FilterByCategories: ICommand {
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

class LoadCategories: ICommand {
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

class LoadFavorites: ICommand {
    typealias Input = Void
    typealias Output = [Meal]?

    func execute(input: Void) async -> [Meal]? {
        do {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
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
            
            //let managedObjectContext = DataController.shared.managedObjectContext
            var result: Result<Meal, SaveFavoriteError>?
            
            try await managedObjectContext.perform {
                
                let fetchedArea = try managedObjectContext.fetch(areaFetchRequest).first
                print("Got meal's area: \(fetchedArea?.name ?? "unknown")")
                let fetchedCategory = try managedObjectContext.fetch(categoryFetchRequest).first
                print("Got meal's category: \(fetchedCategory?.name ?? "unknown")")
                
//                var fetchedIngredients: [Ingredient] = []
//
//                for request in ingredientFetchRequests {
//                    let fetchedIngredient = try managedObjectContext.fetch(request)
//                    fetchedIngredients.append(contentsOf: fetchedIngredient)
//                }
//                print("Got \(fetchedIngredients.count) ingredients in meal")
                
                if let fetchedFavorite = try managedObjectContext.fetch(favoriteFetchRequest).first {
                    fetchedFavorite.name = input.name
                    fetchedFavorite.image = input.image
                    fetchedFavorite.instructions = input.instructions
                    fetchedFavorite.area = fetchedArea
                    fetchedFavorite.category = fetchedCategory
                    fetchedFavorite.ingredients = NSSet(array: ingredientEntities)
                    
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
                    newFavorite.ingredients = NSSet(array: ingredientEntities)
                    
                    print("New favorite created: \(newFavorite.name ?? "unknown name for some reason")")
                    
                    print("This favorite has the following attributes: ")
                    print("id: \(newFavorite.id ?? "unknown id")")
                    print("image: \(newFavorite.image ?? "unknown image")")
                    print("area: \(newFavorite.area?.name ?? "unknown area")")
                    print("category name: \(newFavorite.category?.name ?? "unknown category name")")
                    print("category id: \(newFavorite.category?.id ?? "unknown category id")")
                    print("category image: \(newFavorite.category?.image ?? "unknown category image")")
                    print("category information: \(newFavorite.category?.information ?? "unknown category information")")
                    
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
