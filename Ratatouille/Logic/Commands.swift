//
//  Commands.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 21/11/2023.
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

//class CompleteMealAttributes: ICommand {
//    typealias Input = MealModel
//    typealias Output = MealModel?
//    
//    func execute(input: Input) async -> Output {
//        do {
//            let result = await APIClient.getMeals(input: input.id)
//                
//            switch result {
//                case .success(let idMeals):
//                    return idMeals.first
//                case .failure(let error):
//                    throw error
//            }
//        } catch {
//            print("Unexpected error in fetchAdditionalInformation for FilterByCategoriesCommand: \(error)")
//            return nil
//        }
//    }
//}

// Assigning isFavorite attribute based on match/no match in CoreData
class ConnectAttributesCommand: ICommand {
    typealias Input = [MealModel]
    typealias Output = [MealModel]
    
    func execute(input: [MealModel]) async -> [MealModel] {
        do {
            let managedObjectContext = DataController.shared.managedObjectContext
            
            return try input.map { meal -> MealModel in
                let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", meal.id)
                
                if let match: Meal = try managedObjectContext.fetch(request).first {
                    var updatedMeal = meal
                        updatedMeal.isFavorite = true
                    
                    let request: NSFetchRequest<Archive> = Archive.fetchRequest()
                        request.predicate = NSPredicate(format: "meals CONTAINS %@", match)
                    
                    if let _ = try managedObjectContext.fetch(request).first {
                        updatedMeal.isFavorite = false
                    }
                    
                    return updatedMeal
                } else {
                    return meal
                }
            }
        } catch {
            print("Unexpected error when fetching isFavorite attribute in ConnectAttributesCommand: \(error)")
            return []
        }
    }
}

