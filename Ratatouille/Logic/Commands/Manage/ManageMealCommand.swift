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

// TODO: add new

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
