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

    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var instructions: String?
    @NSManaged public var name: String?
    @NSManaged public var area: Area?
    @NSManaged public var category: Category?
    @NSManaged public var ingredients: NSSet?
}

// MARK: Generated accessors for ingredients --> ubrukt
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

}
