//
//  Category+CoreDataProperties.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//
//

import Foundation
import CoreData


extension Category: CategoryRepresentable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String
    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var information: String?
    @NSManaged public var meals: NSSet?

}

// MARK: Generated accessors for meals
extension Category {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: Meal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: Meal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)

}

extension Category : Identifiable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case image
        case information
    }
}
