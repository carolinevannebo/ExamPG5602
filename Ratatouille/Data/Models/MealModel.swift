//
//  MealModel.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import Foundation
import CoreData


struct MealModel: Codable, Identifiable {
    let id: String
    var name: String
    var image: String?
    var instructions: String?
    var area: AreaModel?
    var category: CategoryModel?
    var ingredients: [IngredientModel]?
    var isFavorite: Bool
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: MealCodingKeys.self)
            let id = try container.decode(String.self, forKey: .idMeal)
            let name = try container.decode(String.self, forKey: .strMeal)
            let image = try container.decodeIfPresent(String.self, forKey: .strMealThumb)
            let instructions = try container.decodeIfPresent(String.self, forKey: .strInstructions)
            let area = try container.decodeIfPresent(String.self, forKey: .strArea)
            let category = try container.decodeIfPresent(String.self, forKey: .strCategory)
            
            var areaModel: AreaModel?
            if area != nil {
                areaModel = try AreaModel(from: decoder)
                areaModel.self?.name = area!
            } else {
                areaModel = nil
            }
            
            var categoryModel: CategoryModel?
            if category != nil {
                categoryModel = try CategoryModel(from: decoder)
                categoryModel.self?.name = category!
                
                // Match the rest of categorymodel's attributes to attributes of category in CoreData
                let managedObjectContext = DataController.shared.managedObjectContext
                let request: NSFetchRequest<Category> = Category.fetchRequest()
                    request.predicate = NSPredicate(format: "name == %@", category!)
                
                if let fetchedCategory = try managedObjectContext.fetch(request).first {
                    // Assign values
                    categoryModel.self?.id = fetchedCategory.id
                    categoryModel.self?.image = fetchedCategory.image
                    categoryModel.self?.information = fetchedCategory.information
                }
            } else {
                categoryModel = nil
            }
            
            let (dynamicIngredientKeys, dynamicMeasureKeys) = MealModel.makeDynamicKeys()
            let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
            
            let dynamicIngredients = try MealModel.decodeDynamicValues(
                container: dynamicContainer,
                ingredientKeys: dynamicIngredientKeys,
                measurementKeys: dynamicMeasureKeys
            )
            
            var ingredientsArr: [IngredientModel] = []
            
            for ingredient in dynamicIngredients {
                var ingredientModel = try IngredientModel(from: decoder)
                if !ingredient.isEmpty {
                    ingredientModel.self.id = UUID().uuidString
                    ingredientModel.self.name = ingredient
                    
                    ingredientsArr.append(ingredientModel)
                }
            }
            
            self.id = id
            self.name = name
            self.image = image
            self.instructions = instructions
            self.area = areaModel
            self.category = categoryModel
            self.ingredients = ingredientsArr.compactMap { $0 }
            self.isFavorite = false
            
        } catch {
            let context = DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Failed to decode Meal entity. \(error.localizedDescription)",
                    underlyingError: error)
            throw DecodingError.dataCorrupted(context)
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
    
    static func decodeDynamicValues(
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
                            if !ingredient.isEmpty, !measurement.isEmpty {
                                let attribute = "\(ingredient.capitalized), \(measurement)"
                                dynamicIngredients.append(attribute)
                            }
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
    
    enum MealErrors: Error { // TODO: error handling
        case decodingError
        case ingredientMismatchError
        
    }
}

enum MealCodingKeys: String, CodingKey {
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

struct MealWrapper: Decodable {
    let meals: [MealModel]
}
