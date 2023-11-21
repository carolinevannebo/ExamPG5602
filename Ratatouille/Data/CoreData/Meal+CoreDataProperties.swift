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

extension Meal {
    static func demoMeal() -> Meal {
        let managedObjectContext = PersistenceController.shared.container.viewContext
        
        let demoMeal = Meal(context: managedObjectContext)
        demoMeal.id = "1"
        demoMeal.name = "Demo Meal"
        demoMeal.instructions = "Demo Instructions"
        demoMeal.image = "demo_image_url"
        
        // Assuming you have an Area and Category in your data model
        let demoArea = Area(context: managedObjectContext)
        demoArea.name = "Demo Area"
        demoMeal.area = demoArea
        
        let demoCategory = Category(context: managedObjectContext)
        demoCategory.id = "1"
        demoCategory.name = "Demo Category"
        demoCategory.image = "demo_category_image_url"
        demoCategory.information = "Lorem ipsum category"
        demoMeal.category = demoCategory
        
        // Add some ingredients (modify according to your Ingredient model)
        let ingredient1 = Ingredient(context: managedObjectContext)
        ingredient1.name = "Ingredient 1"
        
        let ingredient2 = Ingredient(context: managedObjectContext)
        ingredient2.name = "Ingredient 2"
        
        demoMeal.addToIngredients(NSSet(array: [ingredient1, ingredient2]))
        
        return demoMeal
    }
}

extension Meal : Identifiable {

}
