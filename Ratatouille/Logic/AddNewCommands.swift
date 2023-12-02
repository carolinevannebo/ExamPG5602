//
//  AddNewCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 02/12/2023.
//

import Foundation
import CoreData

class AddNewCategoryCommand: ICommand {
    typealias Input = CategoryModel
    typealias Output = Result<Category, AddNewCategoryError>
    
    enum AddNewCategoryError: Error {
        case missingIdError(String)
        case savingError
        case duplicateError
        case imageConversionError
    }
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw AddNewCategoryError.missingIdError("Meal ID is missing.")
            }
            
            let request: NSFetchRequest<Category> = Category.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedCategory = try managedObjectContext.fetch(request).first {
                    
                    print("Category is already saved")
                    result = .failure(.duplicateError)
                } else {
                    let newCategory = Category(context: managedObjectContext)
                    newCategory.id = input.id
                    newCategory.name = input.name
                    
//                    if let imageData = Data(base64Encoded: input.image!) {
//                        newCategory.image = imageData
//                        
//                        result = .success(newCategory)
//                    } else {
//                        print("Failed to convert base64 image string to Data")
//                        result = .failure(.imageConversionError)
//                    }
                    newCategory.image = input.image // veldig mulig du må lagre bildet på annet vis
                    
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
