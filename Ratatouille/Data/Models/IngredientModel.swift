//
//  IngredientModel.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 22/11/2023.
//

import Foundation

struct IngredientModel: Codable, Identifiable, IngredientRepresentable {
    var id: String?
    var name: String?
    var information: String?
    
    init?(id: String, name: String, information: String?) {
        self.id = id
        self.name = name
        self.information = information
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IngredientCodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .idIngredient)
        self.name = try container.decode(String.self, forKey: .strIngredient)
        self.information = try container.decodeIfPresent(String.self, forKey: .strDescription)
    }
}

enum IngredientCodingKeys: CodingKey { // TODO: mulig du vil legge til string for model
    case idIngredient //= "id"
    case strIngredient //= "name"
    case strDescription //= "information"
}

struct IngredientWrapper: Decodable {
    let meals: [IngredientModel] // Has to be meals, to recognize the field in the API
}

