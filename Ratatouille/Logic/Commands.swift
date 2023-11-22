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
            await APIClient.deleteAllRecords(managedObjectContext: input)
//            await APIClient.saveCategories(managedObjectContext: input)
//            await APIClient.saveAreas(managedObjectContext: input)
//            await APIClient.saveIngredients(managedObjectContext: input)
        }
    }
}

class SearchMeals: ICommand {
    typealias Input = String
    typealias Output = [Meal]?
    
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
    typealias Output = Meal?

    func execute(input: Void) async -> Output {
        do {
            let result = await APIClient.getRandomMeal()

            switch result {
                case .success(let meal):
                    print("Got meal: \(meal.name ?? "N/A")")
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
    typealias Output = [Ingredient]?
    
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
    typealias Output = [Area]?
    
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
    typealias Output = [Category]?
    
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
