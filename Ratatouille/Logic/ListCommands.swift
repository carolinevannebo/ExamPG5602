//
//  ListCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 25/11/2023.
//

import Foundation
import UIKit

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
            print("Unexpected error in LoadCategoriesCommand: \(error)")
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
            print("Unexpected error in ListIngredientsCommand: \(error)")
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
            print("Unexpected error in ListAreasCommand: \(error)")
            return nil
        }
    }
}

class FetchFlagCommand: ICommand {
    typealias Input = AreaModel
    typealias Output = UIImage?
    
    func execute(input: AreaModel) async -> Output {
        do {
            let countryCode = FlagAPIClient.CountryCode(rawValue: input.name.lowercased())!
            let flagStyle = FlagAPIClient.FlagStyle.flat
            let flagSize = FlagAPIClient.FlagSize.small
            
            let flag = try await FlagAPIClient.getFlag(countryCode: countryCode, flagStyle: flagStyle, flagSize: flagSize)
            return flag
        } catch {
            print("Unexpected error in FetchFlagCommand: \(error)")
            return nil
        }
    }
}
