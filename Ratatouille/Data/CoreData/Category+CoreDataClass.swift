//
//  Category+CoreDataClass.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//
//

import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject, Decodable {
    
    enum CodingKeys: CodingKey {
        case idCategory
        case strCategory
        case strCategoryThumb
        case strCategoryDescription
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .idCategory)
        let name = try container.decode(String.self, forKey: .strCategory)
        let image = try container.decode(String.self, forKey: .strCategoryThumb)
        let information = try container.decode(String.self, forKey: .strCategoryDescription)
        
        let managedObjectContext = DataController.shared.managedObjectContext
        
        super.init(entity: .entity(forEntityName: "Category", in: managedObjectContext)!, insertInto: managedObjectContext)
        
        self.id = id
        self.name = name
        self.image = image
        self.information = information
    }

}

struct CategoriesWrapper: Decodable {
    let categories: [Category]
}
