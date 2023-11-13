//
//  Ingredient+CoreDataClass.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//
//

import Foundation
import CoreData

@objc(Ingredient)
public class Ingredient: NSManagedObject, Decodable {
    
    enum CodingKeys: CodingKey {
        case idIngredient
        case strIngredient
        case strDescription
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .idIngredient)
        let name = try container.decode(String.self, forKey: .strIngredient)
        let information = try container.decodeIfPresent(String.self, forKey: .strDescription)
        
        let dataController = DataController.shared
        let managedObjectContext = dataController.container.viewContext
        super.init(entity: .entity(forEntityName: "Ingredient", in: managedObjectContext)!, insertInto: managedObjectContext)
        
        self.id = id
        self.name = name
        self.information = information
    }
}

struct IngredientsWrapper: Decodable {
    let meals: [Ingredient] // Has to be meals, to recognize the field in the API
}
