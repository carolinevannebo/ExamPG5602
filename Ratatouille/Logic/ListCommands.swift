//
//  ListCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 25/11/2023.
//

import Foundation

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
