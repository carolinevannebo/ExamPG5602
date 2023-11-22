//
//  MealModel.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import Foundation


struct MealModel: Codable, Identifiable {
    let id: String
    let name: String
    let image: String?
    let instructions: String
    let area: AreaModel?
    let category: CategoryModel?
    let ingredients: [IngredientModel]
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: MealCodingKeys.self)
            let id = try container.decode(String.self, forKey: .idMeal)
            let name = try container.decode(String.self, forKey: .strMeal)
            let image = try container.decodeIfPresent(String.self, forKey: .strMealThumb)
            let area = try container.decode(String.self, forKey: .strArea)
            let category = try container.decode(String.self, forKey: .strCategory)
            let instructions = try container.decode(String.self, forKey: .strInstructions)
            
            var areaModel = try AreaModel(from: decoder)
            areaModel.self.name = area
            //areaModel.name = area
            
            var categoryModel = try CategoryModel(from: decoder)
            categoryModel.self.name = category
            
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
                    print("This ingredient: \(ingredient)")
                    ingredientModel.self.name = ingredient
                    ingredientsArr.append(ingredientModel)
                }
            }
            
            self.id = id
            self.name = name
            self.image = image
            self.area = areaModel
            self.category = categoryModel
            self.instructions = instructions
            self.ingredients = ingredientsArr.compactMap { $0 }
            
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
                        // TODO: make arrays of their entities
                        if !ingredient.isEmpty, !measurement.isEmpty {
                            let attribute = "\(ingredient), \(measurement)"
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
