//
//  Meal+CoreDataClass.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//
//

import Foundation
import CoreData

@objc(Meal)
public class Meal: NSManagedObject, Decodable {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws { 
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            let id = try container.decode(String.self, forKey: .id)
            let name = try container.decode(String.self, forKey: .name)
            let category = try container.decode(Category.self, forKey: .category)
            let area = try container.decode(Area.self, forKey: .area)
            let instructions = try container.decode(String.self, forKey: .instructions)
            let image = try container.decodeIfPresent(String.self, forKey: .image)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            super.init(entity: .entity(forEntityName: "Meal", in: managedObjectContext)!, insertInto: managedObjectContext)
            
            self.id = id
            self.name = name
            self.instructions = instructions
            self.image = image
            
            let categoryEntity = try fetchOrCreateEntity(
                type: Category.self,
                attributeName: "name",
                attributeValue: category,
                attributeName2: nil,
                attributeValue2: nil,
                context: managedObjectContext,
                shouldSave: false
            )
            
            let areaEntity = try fetchOrCreateEntity(
                type: Area.self,
                attributeName: "name",
                attributeValue: area,
                attributeName2: nil,
                attributeValue2: nil,
                context: managedObjectContext,
                shouldSave: false
            )
            
            self.category = categoryEntity
            self.area = areaEntity
            
            let (dynamicIngredientKeys, dynamicMeasureKeys) = Meal.makeDynamicKeys()
            let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
            
            let dynamicIngredients = try decodeDynamicValues(
                container: dynamicContainer,
                ingredientKeys: dynamicIngredientKeys.compactMap { $0 }, // compactMap filters out nil values :) redundant now?
                measurementKeys: dynamicMeasureKeys.compactMap { $0 }
            )
            
            var ingredientSet: [Ingredient] = []
            
            for ingredient in dynamicIngredients {
                let ingredientEntity = try fetchOrCreateEntity(
                    type: Ingredient.self,
                    attributeName: "name",
                    attributeValue: ingredient,
                    attributeName2: nil,
                    attributeValue2: nil,
                    context: managedObjectContext,
                    shouldSave: false
                )
                ingredientSet.append(ingredientEntity)
            } // success
            
            managedObjectContext.perform {
                self.ingredients = NSSet(array: ingredientSet.compactMap { $0 } ) //ingredientSet [Ratatouille.Ingredient] 140703128941760 values -> FILTRER UT NIL
            }
            
        } catch {
            let context = DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Failed to decode Meal entity. \(error.localizedDescription)",
                    underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    private func fetchOrCreateEntity<T: NSManagedObject, U: AttributeType>(
        type: T.Type,
        attributeName: String,
        attributeValue: U, // String
        attributeName2: String?,
        attributeValue2: U?, // String?
        context: NSManagedObjectContext,
        shouldSave: Bool) throws -> T {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
            
        if T.self == Ingredient.self, U.self == String.self {
            let attrValueStr = "\(attributeValue.value)"
            let commaIndex = attrValueStr.firstIndex(of: ",") ?? attrValueStr.endIndex
            let substringValue = attrValueStr[..<commaIndex]
            fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", attributeName, substringValue as CVarArg)
        } else {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", attributeName, attributeValue.value)
        }
            
        do {
            let fetchedEntities = try context.fetch(fetchRequest)
            if let fetchedEntity = fetchedEntities.first { //collection was mutated while being enumerated
                //print("Fetched Entity Name: \(fetchedEntity.name)")
                return fetchedEntity
            } else {
                let newEntity = T(context: context)
                newEntity.setValue(attributeValue, forKey: attributeName)
                
                if attributeName2 != nil {
                    newEntity.setValue(attributeValue2?.value, forKey: attributeName2!)
                }
                
                if shouldSave {
                    do {
                        try context.save()
                    } catch {
                        print("Error saving new entity: \(error)")
                        throw error
                    }
                }
                    
                return newEntity
            }
        } catch {
            print("Error fetching entities: \(error)")
            throw error
        }
    }
}

//struct MealsWrapper: Decodable {
//    let meals: [Meal]
//}

protocol AttributeType {
    associatedtype CoreDataType: CVarArg
    var value: CoreDataType { get }
}

extension String: AttributeType {
    var value: String { return self }
}

extension NSManagedObject: AttributeType {
    var value: NSManagedObject { return self }
}
