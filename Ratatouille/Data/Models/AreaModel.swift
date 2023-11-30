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
    
    init?(name: String) {
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

