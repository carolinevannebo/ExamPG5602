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
        case strIngredient = "strIngredient"
        case strMeasure = "strMeasure"
        
        init?(stringValue: String) { self.init(rawValue: stringValue) }
        var stringValue: String { return rawValue }
        init?(intValue: Int) { return nil }
    }
    
//    struct DynamicKeys: CodingKey, Hashable {
//        var stringValue: String
//
//        init(stringValue: String) {
//            self.stringValue = stringValue
//        }
//
//        var intValue: Int? {
//            return nil
//        }
//
//        init?(intValue: Int) {
//            return nil
//        }
//    }
    
    
//    enum DynamicCodingKeys: String, CodingKey {
//        case strIngredient = "strIngredient"
//        case strMeasure = "strMeasure"
//
////        init?(stringValue: String) { self.init(rawValue: stringValue) }
////        var stringValue: String { return rawValue }
////        init?(intValue: Int) { return nil }
//    }
    
    private func fetchOrCreateEntity<T: NSManagedObject>(
        type: T.Type,
        attributeName: String,
        attributeValue: String,
        attributeName2: String?,
        attributeValue2: String?,
        context: NSManagedObjectContext) throws -> T {
            
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = NSPredicate(format: "\(attributeName) == %@", attributeValue)

        if let fetchedEntity = try context.fetch(fetchRequest).first {
            return fetchedEntity
        } else {
            let newEntity = T(context: context)
            newEntity.setValue(attributeValue, forKey: attributeName)
            
            if attributeName2 != nil {
                newEntity.setValue(attributeValue2, forKey: attributeName2!)
            }

            do {
                try context.save()
            } catch {
                print("Error saving new entity: \(error)")
            }

            return newEntity
        }
    }
    
//    private func decodeDynamicValues(
//        container: KeyedDecodingContainer<CodingKeys>,
//        ingredientKey: CodingKeys,
//        measurementKey: CodingKeys
//    ) throws -> ([String], [String]) {
//        do {
//            print("About to decode dynamically into dictionaries")
//            // Decode dynamically into dictionaries
//            let ingredientsDict = try container.decode([String: String?].self, forKey: ingredientKey)
//
//            let measurementsDict = try container.decode([String: String?].self, forKey: measurementKey)
//
//            print("About to filter keys that match the pattern strIngredient + measurements")
//            // Filter keys that match the pattern "strIngredient\d+" + measurements
//            let dynamicIngredientKeys = ingredientsDict.keys.filter { $0.hasPrefix("strIngredient") }
//            let dynamicMeasurementKeys = measurementsDict.keys.filter { $0.hasPrefix("strMeasure") }
//
//            print("About to sort keys based on the numeric part")
//            // Sort keys based on the numeric part
//            let sortedDynamicIngredientKeys = dynamicIngredientKeys.sorted { (key1, key2) in
//                Int(key1.suffix(from: key1.index(after: key1.firstIndex(of: "t")!))) ?? 0 <
//                    Int(key2.suffix(from: key2.index(after: key2.firstIndex(of: "t")!))) ?? 0
//            }
//
//            let sortedDynamicMeasurementKeys = dynamicMeasurementKeys.sorted { (key1, key2) in
//                Int(key1.suffix(from: key1.index(after: key1.lastIndex(of: "e")!))) ?? 0 <
//                    Int(key2.suffix(from: key2.index(after: key2.lastIndex(of: "e")!))) ?? 0
//            }
//
//            print("About to extract values in order")
//            // Extract values in order
//            var dynamicIngredients: [String] = []
//            var dynamicMeasurements: [String] = []
//
//            print("About to iterate keys to append to arrays")
//            for key in sortedDynamicIngredientKeys {
//                // Append ingredient to the array, use an empty string if it's nil or NSNull
//                if let ingredient = ingredientsDict[key], ingredient != nil {
//                    dynamicIngredients.append(ingredient!)
//                }
//            }
//
//            for key in sortedDynamicMeasurementKeys {
//                // Append measurement to the array, use an empty string if it's nil or NSNull/
//                if let measurement = measurementsDict[key], measurement != nil {
//                    dynamicMeasurements.append(measurement!)
//                }
//            }
//
//            print("About to return")
//            return (dynamicIngredients, dynamicMeasurements)
//        } catch {
//            print("Error decoding dynamic values: \(error)")
//            return ([], [])
//        }
//    }
    
    private func decodeDynamicValues(
        container: KeyedDecodingContainer<CodingKeys>,
        ingredientKey: String,
        measurementKey: String
    ) throws -> ([String], [String]) {
        do {
            
            print("Declaring arrays")
            var dynamicIngredients: [String] = []
            var dynamicMeasurements: [String] = []
            
            for i in 1...20 {
                print("Declaring keys: ")
                
                let currentIngredientKey = "\(ingredientKey)\(i)"
                let currentMeasurementKey = "\(measurementKey)\(i)"

                print("We want: \(currentIngredientKey)")
                print("We want: \(currentMeasurementKey)")
                
                print("About to decode \(i)")
                
                do {
                    //nil
                    let ingredientCodingKey = CodingKeys(stringValue: currentIngredientKey) ?? .strIngredient
                    let measurementCodingKey = CodingKeys(stringValue: currentMeasurementKey) ?? .strMeasure

                    print("We got: \(ingredientCodingKey)")
                    print("We got: \(String(describing: measurementCodingKey.stringValue))")
                    
                    if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientCodingKey), //CRASHING HERE // ingredientCodingKey
                       let measurement = try container.decodeIfPresent(String.self, forKey: measurementCodingKey) { // measurementCodingKey
                        
                        // Append ingredient and measurement to your arrays if they are not nil
                        print("About to append values to arrays if they are not nil")
                        dynamicIngredients.append(ingredient)
                        dynamicMeasurements.append(measurement)
                      
                    } else {
                        print("ingredient and/or measurement cant be decoded")
                    }
                } catch {
                    print("Something went wrong")
                    throw error
                }
            }

            print("About to return")
            return (dynamicIngredients, dynamicMeasurements)
        } catch {
            print("Error decoding dynamic values: \(error)")
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
            
            self.category = try fetchOrCreateEntity(type: Category.self, attributeName: "name", attributeValue: category, attributeName2: nil,    attributeValue2: nil, context: managedObjectContext)
            self.area = try fetchOrCreateEntity(type: Area.self, attributeName: "name", attributeValue: area, attributeName2: nil, attributeValue2: nil, context: managedObjectContext)
            
            print("About to attempt the headache")
//            let (dynamicIngredients, dynamicMeasurements) = try decodeDynamicValues(
//                container: container,
//                ingredientKey: CodingKeys.strIngredient.stringValue,
//                measurementKey: CodingKeys.strMeasure.stringValue
//            )
            
            // start of function
            do {
                
                print("Declaring arrays")
                var dynamicIngredients: [String] = []
                var dynamicMeasurements: [String] = []
                
                for i in 1...20 {
                    print("Declaring keys: ")
                    
                    let currentIngredientKey = "\(CodingKeys.strIngredient.stringValue)\(i)"
                    let currentMeasurementKey = "\(CodingKeys.strMeasure.stringValue)\(i)"

                    print("We want: \(currentIngredientKey)")
                    print("We want: \(currentMeasurementKey)")
                    
                    print("About to decode \(i)")
                    
                    do {
                        //nil
                        var ingredientCodingKey = CodingKeys(stringValue: currentIngredientKey) ?? CodingKeys.strIngredient.stringValue.appending(String(i)).codingKey
                        var measurementCodingKey = CodingKeys(stringValue: currentMeasurementKey) ?? CodingKeys.strMeasure.stringValue.appending(String(i)).codingKey
                        //?? .strMeasure

                        print("We got: \(ingredientCodingKey.stringValue)")
                        print("We got: \(measurementCodingKey.stringValue)")
                        
                        if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientCodingKey as! CodingKeys), // ingredientCodingKey
                           let measurement = try container.decodeIfPresent(String.self, forKey: measurementCodingKey as! CodingKeys) { // measurementCodingKey
                            
                            // Append ingredient and measurement to your arrays if they are not nil
                            print("About to append values to arrays if they are not nil")
                            dynamicIngredients.append(ingredient)
                            dynamicMeasurements.append(measurement)
                          
                        } else {
                            print("ingredient and/or measurement cant be decoded")
                        }
                        
                    } catch {
                        print("Something went wrong")
                        throw error
                    }
                }
                
                dynamicIngredients.isEmpty ? print("ingredients empty") : print("ingredients not empty")
                guard dynamicIngredients.count == dynamicMeasurements.count else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .strIngredient,
                        in: container,
                        debugDescription: "Mismatched number of ingredients and measurements."
                    )
                }

            } catch {
                print("Error decoding dynamic values: \(error)")
            }
            
            // end of function
            
            //dynamicIngredients.isEmpty ? print("ingredients empty") : print("ingredients not empty")
            
            // Ensure there are the same number of ingredients and measurements
//            guard dynamicIngredients.count == dynamicMeasurements.count else {
//                throw DecodingError.dataCorruptedError(
//                    forKey: .strIngredient,
//                    in: container,
//                    debugDescription: "Mismatched number of ingredients and measurements."
//                )
//            }

//            self.ingredients = NSSet(array: zip(dynamicIngredients, dynamicMeasurements).map { ingredient, measurement in
//
//                let ingredientEntity = Ingredient(context: managedObjectContext)
//                ingredientEntity.name = ingredient
//                //ingredientEntity.measurement = measurement hvor faen skal du????
//                return ingredientEntity
//            })
            
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

//if let students = try container.decodeIfPresent([Student].self, forKey: .students)
//        {
//            self.students = NSSet(array: students)
//            for student in students {
//                student.school = self
//            }
//
//        } else {
//            self.students = NSSet()
//        }
