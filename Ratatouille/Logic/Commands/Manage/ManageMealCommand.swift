//
//  ManageMealCommand.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 04/12/2023.
//

import Foundation
import CoreData

enum ManageMealError: Error {
    case missingIdError(String)
    case duplicateError
    case fetchError
    case updateError
    case savingError
}

class AddNewMealCommand: ICommand {
    typealias Input = MealModel
    typealias Output = Result<Meal, ManageMealError>
    
    func execute(input: MealModel) async -> Result<Meal, ManageMealError> {
        do {
            if input.id.isEmpty {
                throw ManageMealError.missingIdError("Meal ID is missing.")
            }
                    
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", input.id)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedMeal = try managedObjectContext.fetch(request).first {
                    
                    print("Meal with name \(fetchedMeal.name) is already saved")
                    result = .failure(.duplicateError)
                } else {
                    let newMeal = Meal(context: managedObjectContext)
                        newMeal.id = input.id
                        newMeal.name = input.name
                        newMeal.image = input.image
                        newMeal.instructions = input.instructions
                        newMeal.isArchived = false
                    
                    Task {
                        let newCategoryResult = await AddNewCategoryCommand().execute(input: input.category!)
                        switch newCategoryResult {
                            case .success(let newCategory):
                                newMeal.category = newCategory
                            case .failure(let error):
                                print("Could not create new category to new meal: \(error)")
                        }
                    }
                    
                    Task {
                        let newAreaResult = await AddNewAreaCommand().execute(input: input.area!)
                        switch newAreaResult {
                            case .success(let newArea):
                                newMeal.area = newArea
                            case .failure(let error):
                                print("Could not create new area to new meal \(error)")
                        }
                    }
                    
                    result = .success(newMeal)
                }
            }
            
            DataController.shared.saveContext()
            return result ?? .failure(.savingError)
            
        } catch {
            print("Unexpected error in AddNewMealCommand: \(error)")
            return .failure(error as! ManageMealError)
        }
    }
}

class UpdateMealCommand: ICommand {
    typealias Input = Meal
    typealias Output = Result<Meal, ManageMealError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id.isEmpty {
                throw ManageMealError.missingIdError("Meal ID is missing.")
            }
            
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedMeal = try managedObjectContext.fetch(request).first {
                    if !input.name.isEmpty {
                        fetchedMeal.name = input.name
                    }
                    fetchedMeal.instructions = input.instructions!
                    fetchedMeal.image = input.image!
                    
                    result = .success(fetchedMeal)
                } else {
                    result = .failure(.fetchError)
                }
            }
            
            DataController.shared.saveContext()
            return result ?? .failure(.updateError)
        } catch {
            print("Unexpected error in UpdateMealCommand: \(error)")
            return .failure(error as! ManageMealError)
        }
    }
}
