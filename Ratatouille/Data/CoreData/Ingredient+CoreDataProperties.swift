//
//  Ingredient+CoreDataProperties.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 20/11/2023.
//
//

import Foundation
import CoreData


extension Ingredient: IngredientRepresentable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var id: String?
    @NSManaged public var information: String?
    @NSManaged public var name: String?
    @NSManaged public var image: String?
    @NSManaged public var meals: NSSet?
    @NSManaged public var archive: Archive?
}

// MARK: Generated accessors for meals
extension Ingredient {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: Meal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: Meal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)

}

extension Ingredient : Identifiable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case information
        case image
    }
}
