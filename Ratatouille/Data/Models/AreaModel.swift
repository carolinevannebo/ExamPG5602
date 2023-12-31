//
//  AreaModel.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 22/11/2023.
//

import Foundation
import UIKit

struct AreaModel: Codable, AreaRepresentable {
    var name: String
    var id: String?
    
    init?(name: String, id: String?) {
        self.name = name
        self.id = id
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
    var meals: [AreaModel] // Has to be meals, to recognize the field in the API
}

