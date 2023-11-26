//
//  AreaModel.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import Foundation

struct AreaModel: Codable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AreaCodingKeys.self)
        let name = try container.decode(String.self, forKey: .strArea)
        self.name = name
    }
}

enum AreaCodingKeys: CodingKey {
    case strArea
}

struct AreaWrapper: Decodable {
    let meals: [AreaModel] // Has to be meals, to recognize the field in the API
}
