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
            fetchRequest.predicate = NSPredicate(format: "\(attributeName) == %@", attributeValue) // la til value //as! CVarArg

        if let fetchedEntity = try context.fetch(fetchRequest).first {
            return fetchedEntity
        } else {
            let newEntity = T(context: context)
            newEntity.setValue(attributeValue, forKey: attributeName) // la til value
            
//            if attributeName2 != nil {
//                newEntity.setValue(attributeValue2, forKey: attributeName2!)
//            }
            if let attributeName2 = attributeName2, let attributeValue2 = attributeValue2 {
                newEntity.setValue(attributeValue2.value, forKey: attributeName2) // la til value
            }

            if shouldSave {
                do {
                    try context.save()
                } catch {
                    print("Error saving new entity: \(error)")
                }
            }

            return newEntity
        }
    }
    
    private func decodeDynamicValues(
        container: KeyedDecodingContainer<DynamicCodingKeys>,
        ingredientKeys: [String],
        measurementKeys: [String]
    ) throws -> ([String], [String]) {
        do {
            
//            print("Declaring arrays")
            var dynamicIngredients: [String] = []
            var dynamicMeasurements: [String] = []
            
            let count = min(ingredientKeys.count, measurementKeys.count) // only iterate the present values
            for i in 0..<count {
//                print("Declaring keys: ")
                
                let currentIngredientKey = ingredientKeys[i]
                let currentMeasurementKey = measurementKeys[i]

//                print("We got: \(currentIngredientKey)")
//                print("We got: \(currentMeasurementKey)")
//
//                print("About to decode \(i+1)")
                
                do {
                    let ingredientKey = DynamicCodingKeys(stringValue: currentIngredientKey)
                    let measurementKey = DynamicCodingKeys(stringValue: currentMeasurementKey)
                        
                    if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientKey),
                       let measurement = try container.decodeIfPresent(String.self, forKey: measurementKey) {
                        // TODO: make arrays of their entities
                        dynamicIngredients.append(ingredient)
                        dynamicMeasurements.append(measurement)
                        
                        print("--------- The order we want -----------")
                        print("Ingredient: \(String.init(ingredient).utf8), Measurement: \(String.init(measurement).utf8)")
                    }
                    
                } catch {
                    throw error
                }
            } // end of loop

            return (dynamicIngredients, dynamicMeasurements)
        } catch {
            print("Error decoding dynamic values: \(error)")
            return ([], [])
        }
    }
    
    private func assertArrays(managedObjectContext: NSManagedObjectContext, ingredientStrings: [String], measurementStrings: [String]) -> ([Ingredient], [Measurement]) {
        var ingredientSet: [Ingredient] = []
        var measurementSet: [Measurement] = []

        do {
            let count = min(ingredientStrings.count, measurementStrings.count) // only iterate the present values
            for i in 0..<count {
            //for (ingredientString, measurementString) in zip(ingredientStrings, measurementStrings) {
                
                let ingredientEntity = try fetchOrCreateEntity(
                    type: Ingredient.self,
                    attributeName: "name",
                    attributeValue: ingredientStrings[i],
                    attributeName2: nil,
                    attributeValue2: "nil",
                    context: managedObjectContext,
                    shouldSave: true
                ) // TODO: irr med "" istedenfor nil
                
                ingredientSet.append(ingredientEntity)
                
                let measurementEntity = try fetchOrCreateEntity(
                    type: Measurement.self,
                    attributeName: "amount",
                    attributeValue: measurementStrings[i],
                    attributeName2: "ingredient",
                    attributeValue2: ingredientEntity as Ingredient,
                    context: managedObjectContext,
                    shouldSave: false
                ) // TODO: gir dette mening mtp CoreData ??
                
                measurementSet.append(measurementEntity)
                
                print("--------- The order we got -----------")
                print("Ingredient: \(String(describing: ingredientEntity.name)), Measurement: \(String(describing: measurementEntity.amount))")
            }
            
            return (ingredientSet, measurementSet)
        } catch {
            print("Error asserting ingredient/measurement arrays: \(error)")
            return ([], [])
        }
    }

    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            let id = try container.decode(String.self, forKey: .idMeal)
            let name = try container.decode(String.self, forKey: .strMeal)
            let category = try container.decode(String.self, forKey: .strCategory)
            let area = try container.decode(String.self, forKey: .strArea)
            let instructions = try container.decode(String.self, forKey: .strInstructions)
            let image = try container.decodeIfPresent(String.self, forKey: .strMealThumb)
            
            
            let dataController = DataController.shared
            let managedObjectContext = dataController.container.viewContext
            super.init(entity: .entity(forEntityName: "Meal", in: managedObjectContext)!, insertInto: managedObjectContext)
            
            self.id = id
            self.name = name
            self.instructions = instructions
            self.image = image
            
            self.category = try fetchOrCreateEntity(
                type: Category.self,
                attributeName: "name",
                attributeValue: category,
                attributeName2: nil,
                attributeValue2: "nil",
                context: managedObjectContext,
                shouldSave: true
            ) // TODO: irr med "" istedenfor nil
            
            self.area = try fetchOrCreateEntity(
                type: Area.self,
                attributeName: "name",
                attributeValue: area,
                attributeName2: nil,
                attributeValue2: "nil",
                context: managedObjectContext,
                shouldSave: true
            ) // TODO: irr med "" istedenfor nil
            
            let (dynamicIngredientKeys, dynamicMeasureKeys) = Meal.makeDynamicKeys()
            let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
            
            let (dynamicIngredients, dynamicMeasurements) = try decodeDynamicValues(
                container: dynamicContainer,
                ingredientKeys: dynamicIngredientKeys.compactMap { $0 }, // compactMap filters out nil values :) redundant now
                measurementKeys: dynamicMeasureKeys.compactMap { $0 }
            )
            
            // Ensure there are the same number of ingredients and measurements
            guard dynamicIngredients.count == dynamicMeasurements.count else {
                throw MealErrors.ingredientMismatchError // TODO: errors
            }
            
            let (ingredientSet, measurementSet) = assertArrays(managedObjectContext: managedObjectContext, ingredientStrings: dynamicIngredients, measurementStrings: dynamicMeasurements)
            
            // Ensure there are the same number of ingredients and measurements
            guard ingredientSet.count == measurementSet.count else {
                throw MealErrors.ingredientMismatchError // TODO: errors
            }
            
            self.ingredients = Set(ingredientSet) //NSSet(array: ingredientSet)
            self.measurements = Set(measurementSet)
            
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
    //typealias CoreDataType = String // might be redundant
    var value: String { return self }
}

extension NSManagedObject: AttributeType {
    //typealias CoreDataType = NSManagedObject // might be redundant
    var value: NSManagedObject { return self }
}


enum MealErrors: Error { // TODO: error handling
    case decodingError
    case ingredientMismatchError
    
}
