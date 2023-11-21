//
//  Commands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import Foundation

public protocol ICommand {
    associatedtype Input
    associatedtype Output
    
    func execute(input: Input) async -> Output
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
                    throw error
            }
        } catch {
            print("Unexpected error: \(error)")
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
