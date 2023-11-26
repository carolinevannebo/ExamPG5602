//
//  CategoryModel.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import Foundation

struct CategoryModel: Codable, Identifiable {
    var id: String?
    var name: String
    var image: String?
    var information: String?
    
    init(id: String?, name: String, image: String, information: String) {
        self.id = id
        self.name = name
        self.image = image
        self.information = information
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CategoryCodingKeys.self)
        let id = try container.decodeIfPresent(String.self, forKey: .idCategory)
        let name = try container.decode(String.self, forKey: .strCategory)
        let image = try container.decodeIfPresent(String.self, forKey: .strCategoryThumb)
        let information = try container.decodeIfPresent(String.self, forKey: .strCategoryDescription)
        
        self.id = id
        self.name = name
        self.image = image
        self.information = information
    }
}

enum CategoryCodingKeys: CodingKey {
    case idCategory
    case strCategory
    case strCategoryThumb
    case strCategoryDescription
}

struct CategoryWrapper: Decodable {
    let categories: [CategoryModel]
}
