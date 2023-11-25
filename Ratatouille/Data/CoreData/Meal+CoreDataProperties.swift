//
//  Meal+CoreDataProperties.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 20/11/2023.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var id: String
    @NSManaged public var image: String?
    @NSManaged public var instructions: String?
    @NSManaged public var name: String?
    @NSManaged public var area: Area?
    @NSManaged public var category: Category?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var isArchived: Bool
}

// MARK: Generated accessors for ingredients
extension Meal {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension Meal : Identifiable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case area
        case instructions
        case image
        case ingredients
        case isArchived
    }
    
    enum MealErrors: Error { // TODO: error handling
        case decodingError
        case ingredientMismatchError
        
    }
}
