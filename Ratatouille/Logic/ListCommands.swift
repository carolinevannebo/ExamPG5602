//
//  ListCommands.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 25/11/2023.
//

import Foundation
import UIKit
import CoreData

class FetchFlagCommand: ICommand {
    typealias Input = String
    typealias Output = UIImage?
    
    func execute(input: Input) async -> Output {
        do {
            if let countryCode = FlagAPIClient.CountryCode.nameToCode[input.lowercased()] {
                let flagStyle = FlagAPIClient.FlagStyle.flat
                let flagSize = FlagAPIClient.FlagSize.small
                
                do {
                    let flag = try await FlagAPIClient.getFlag(countryCode: countryCode, flagStyle: flagStyle, flagSize: flagSize)
                    return flag
                } catch {
                    print("Error while fetching flag: \(error)")
                    throw error
                }
            }
        } catch {
            print("Unexpected error in FetchFlagCommand: \(error)")
            return nil
        }
        return nil
    }
}

class LoadAreasFromCDCommand: ICommand {
    typealias Input = Void
    typealias Output = [Area]?

    func execute(input: Input) async -> Output {
        do {
            let request: NSFetchRequest<Area> = Area.fetchRequest()
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            let areas: [Area] = try managedObjectContext.fetch(request)
            
            return areas
        } catch {
            print("Unexpected error in LoadAreasFromCDCommand: \(error)")
            return nil
        }
    }
}

class LoadCategoriesFromCDCommand: ICommand {
    typealias Input = Void
    typealias Output = [Category]?
    
    func execute(input: Input) async -> Output {
        do {
            let managedObjectContext = DataController.shared.managedObjectContext
            
            let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
            let allCategories = try managedObjectContext.fetch(categoryRequest)

            
            let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                archiveRequest.predicate = NSPredicate(format: "ANY categories IN %@", allCategories)
            let archives = try managedObjectContext.fetch(archiveRequest)
            
            let categoriesInArchives = archives.compactMap { $0.categories as? Set<Category> }.flatMap { $0 }
            let categoriesNotInArchives = allCategories.filter { category in
                !categoriesInArchives.contains { archiveCategory -> Bool in
                    // comparing categories
                    return archiveCategory.id == category.id
                }
            }
            
            return categoriesNotInArchives
            
        } catch {
            print("Unexpected error in LoadCategoriesFromCDCommand: \(error)")
            return nil
        }
    }
}

class LoadIngredientsFromCDCommand: ICommand {
    typealias Input = Void
    typealias Output = [Ingredient]?
    
    func execute(input: Input) async -> Output {
        do {
            let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            let ingredients: [Ingredient] = try managedObjectContext.fetch(request)
            
            return ingredients
            
        } catch {
            print("Unexpected error in LoadIngredientsFromCDCommand: \(error)")
            return nil
        }
    }
}

// MARK: I used these functions until I realized the exam asked for this data from CD, not the api. They did however function as expected.

class LoadAreasFromAPICommand: ICommand {
    typealias Input = Void
    typealias Output = [AreaModel]?

    func execute(input: Input) async -> Output {
        do {
            let result = await APIClient.getAreas()

            switch result {
                case .success(let areas):
                    print("Got \(areas.count) areas")
                    return areas
                case .failure(let error):
                    throw error
            }
        } catch {
            print("Unexpected error in LoadAreasCommand: \(error)")
            return nil
        }
    }
}

class LoadCategoriesFromAPICommand: ICommand {
    typealias Input = Void
    typealias Output = [CategoryModel]?
    
    func execute(input: Input) async -> Output {
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

class LoadIngredientsFromAPICommand: ICommand {
    typealias Input = Void
    typealias Output = [IngredientModel]?

    func execute(input: Input) async -> Output {
        do {
            let result = await APIClient.getIngredients()

            switch result {
                case .success(let ingredients):
                    print("Got \(ingredients.count) ingredients")
                    return ingredients
                case .failure(let error):
                    throw error
            }
        } catch {
            print("Unexpected error in LoadIngredientsCommand: \(error)")
            return nil
        }
    }
}

