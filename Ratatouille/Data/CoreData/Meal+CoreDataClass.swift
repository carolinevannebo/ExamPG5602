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
    
    enum CodingKeys: String, CodingKey {
        case idMeal
        case strMeal
        case strCategory
        case strArea
        case strInstructions
        case strMealThumb
    }
    
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int? {
            return nil
        }

        init?(intValue: Int) {
            return nil
        }
    }
    
    static func makeDynamicKeys() -> ([String], [String]) {
        var dynamicIngredientKeys: [String] = []
        var dynamicMeasureKeys: [String] = []

        for i in 0..<20 {
            dynamicIngredientKeys.append("strIngredient\(i+1)")
            dynamicMeasureKeys.append("strMeasure\(i+1)")
        }
        return (dynamicIngredientKeys, dynamicMeasureKeys)
    }
    
    private func fetchOrCreateEntity<T: NSManagedObject, U: AttributeType>(
        type: T.Type,
        attributeName: String,
        attributeValue: String, // String
        attributeName2: String?,
        attributeValue2: U?, // String?
        context: NSManagedObjectContext,
        shouldSave: Bool) throws -> T {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        //fetchRequest.predicate = NSPredicate(format: "name == %@", attributeValue)
            
        if T.self == Ingredient.self {
            let commaIndex = attributeValue.firstIndex(of: ",") ?? attributeValue.endIndex
            let substringValue = attributeValue[..<commaIndex]
            fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", attributeName, substringValue as CVarArg)
        } else {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", attributeName, attributeValue)
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
    
    private func decodeDynamicValues(
        container: KeyedDecodingContainer<DynamicCodingKeys>,
        ingredientKeys: [String],
        measurementKeys: [String]
    ) throws -> [String] {
        do {
            var dynamicIngredients: [String] = []
            
            let count = min(ingredientKeys.count, measurementKeys.count) // only iterate the present values
            for i in 0..<count {
                
                let currentIngredientKey = ingredientKeys[i]
                let currentMeasurementKey = measurementKeys[i]
                
                do {
                    let ingredientKey = DynamicCodingKeys(stringValue: currentIngredientKey)
                    let measurementKey = DynamicCodingKeys(stringValue: currentMeasurementKey)
                        
                    if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientKey),
                       let measurement = try container.decodeIfPresent(String.self, forKey: measurementKey) {
                        // TODO: make arrays of their entities
                        let attribute = "\(ingredient), \(measurement)"
                        dynamicIngredients.append(attribute)
                    }
                    
                } catch {
                    throw error
                }
            } // end of loop

            return dynamicIngredients
        } catch {
            print("Error decoding dynamic values: \(error)")
            return []
        }
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws { // TODO: tror async ble lagt til her ved uhell
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            let id = try container.decode(String.self, forKey: .idMeal)
            let name = try container.decode(String.self, forKey: .strMeal)
            let category = try container.decode(String.self, forKey: .strCategory)
            let area = try container.decode(String.self, forKey: .strArea)
            let instructions = try container.decode(String.self, forKey: .strInstructions)
            let image = try container.decodeIfPresent(String.self, forKey: .strMealThumb)
            
            let dataController = DataController.shared // testing shared instance after multi-threading crash
            let managedObjectContext = dataController.container.viewContext
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
                attributeValue2: "nil",
                context: managedObjectContext,
                shouldSave: false
            ) // TODO: irr med "" istedenfor nil
            
            let areaEntity = try fetchOrCreateEntity(
                type: Area.self,
                attributeName: "name",
                attributeValue: area,
                attributeName2: nil,
                attributeValue2: "nil",
                context: managedObjectContext,
                shouldSave: false
            ) // TODO: irr med "" istedenfor nil
            
            self.category = categoryEntity
            self.area = areaEntity
            
            let (dynamicIngredientKeys, dynamicMeasureKeys) = Meal.makeDynamicKeys()
            let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
            
            let dynamicIngredients = try decodeDynamicValues(
                container: dynamicContainer,
                ingredientKeys: dynamicIngredientKeys.compactMap { $0 }, // compactMap filters out nil values :) redundant now
                measurementKeys: dynamicMeasureKeys.compactMap { $0 }
            )
            
            var ingredientSet: [Ingredient] = []
            
            for ingredient in dynamicIngredients {
                let ingredientEntity = try fetchOrCreateEntity(
                    type: Ingredient.self,
                    attributeName: "name",
                    attributeValue: ingredient,
                    attributeName2: nil,
                    attributeValue2: "nil",
                    context: managedObjectContext,
                    shouldSave: false
                )
                ingredientSet.append(ingredientEntity)
            } // success
            
            print("meal will be given \(ingredientSet.count) ingredients")
            managedObjectContext.perform {
                self.ingredients = NSSet(array: ingredientSet.compactMap { $0 } ) //ingredientSet [Ratatouille.Ingredient] 140703128941760 values -> FILTRER UT NIL
            }
            print("meal has been given \(String(describing: self.ingredients?.count)) ingredients")
            
        } catch {
            let context = DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Failed to decode Meal entity. \(error.localizedDescription)",
                    underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }
}

struct MealsWrapper: Decodable {
    let meals: [Meal]
}

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


enum MealErrors: Error { // TODO: error handling
    case decodingError
    case ingredientMismatchError
    
}
