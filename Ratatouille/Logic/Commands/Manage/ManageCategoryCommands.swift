//
//  ManageCategoryCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 02/12/2023.
//

import Foundation
import CoreData

enum ManageCategoryError: Error {
    case missingIdError(String)
    case unauthorizedError
    case duplicateError
    case fetchError
    case imageConversionError
    case updateError
    case savingError
}

class AddNewCategoryCommand: ICommand {
    typealias Input = CategoryModel
    typealias Output = Result<Category, ManageCategoryError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw ManageCategoryError.missingIdError("Category ID is missing.")
            }
            
            let request: NSFetchRequest<Category> = Category.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedCategory = try managedObjectContext.fetch(request).first {
                    
                    print("Category with name \(fetchedCategory.name) is already saved")
                    result = .failure(.duplicateError)
                } else {
                    let newCategory = Category(context: managedObjectContext)
                    newCategory.id = input.id
                    newCategory.name = input.name
                    newCategory.image = input.image
                    newCategory.information = input.information
                    
                    result = .success(newCategory)
                }
            }
            
            DataController.shared.saveContext()
            return result ?? .failure(.savingError)
            
        } catch {
            print("Unexpected error in AddNewCategoryCommand: \(error)")
            return .failure(.savingError)
        }
    }
}

class UpdateCategoryCommand: ICommand {
    typealias Input = Category
    typealias Output = Result<Category, ManageCategoryError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw ManageCategoryError.missingIdError("Category ID is missing.")
            }
            
            // Only allow user to update categories they have created
            for i in 0..<14 {
                if input.id == String(i+1) {
                    throw ManageCategoryError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedCategory = try managedObjectContext.fetch(request).first {
                    fetchedCategory.name = input.name
                    fetchedCategory.information = input.information
                    fetchedCategory.image = input.image
                    
                    result = .success(fetchedCategory)
                } else {
                    result = .failure(.fetchError)
                }
            }
            
            DataController.shared.saveContext()
            return result ?? .failure(.updateError)
        } catch {
            print("Unexpected error in UpdateCategoryCommand: \(error)")
            return .failure(.updateError)
        }
    }
}


