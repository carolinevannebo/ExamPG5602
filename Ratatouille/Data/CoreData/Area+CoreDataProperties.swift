//
//  Area+CoreDataProperties.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//
//

import Foundation
import CoreData

extension Area: AreaRepresentable {    

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Area> {
        return NSFetchRequest<Area>(entityName: "Area")
    }

    @NSManaged public var name: String
    @NSManaged public var id: String?
    @NSManaged public var meals: NSSet?
    @NSManaged public var archive: Archive?
}

// MARK: Generated accessors for meals
extension Area {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: Meal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: Meal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)

}

extension Area : Identifiable {
    enum CodingKeys: CodingKey {
        case name
        case id
    }
}

