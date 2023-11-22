//
//  IngredientModel.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import Foundation

struct IngredientModel: Codable, Identifiable {
    var id: String?
    var name: String?
    var information: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IngredientCodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .idIngredient)
        self.name = try container.decodeIfPresent(String.self, forKey: .strIngredient)
        self.information = try container.decodeIfPresent(String.self, forKey: .strDescription)
    }
}

enum IngredientCodingKeys: CodingKey {
    case idIngredient
    case strIngredient
    case strDescription
}

struct IngredientWrapper: Decodable {
    let meals: [IngredientModel] // Has to be meals, to recognize the field in the API
}
