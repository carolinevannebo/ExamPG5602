//
//  Archive+CoreDataProperties.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 25/11/2023.
//
//

import Foundation
import CoreData


extension Archive {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Archive> {
        return NSFetchRequest<Archive>(entityName: "Archive")
    }

    @NSManaged public var areas: NSSet?
    @NSManaged public var categories: NSSet?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var meals: NSSet?

}

// MARK: Generated accessors for meals
extension Archive {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: Meal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: Meal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)
    
    //
    
    @objc(addAreasObject:)
    @NSManaged public func addToAreas(_ value: Area)

    @objc(removeAreasObject:)
    @NSManaged public func removeFromAreas(_ value: Area)

    @objc(addAreas:)
    @NSManaged public func addToAreas(_ values: NSSet)

    @objc(removeAreas:)
    @NSManaged public func removeFromAreas(_ values: NSSet)
    
    //
    
    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Category)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Category)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

    //
    
    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)
}

extension Archive : Identifiable {

}
