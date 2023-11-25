//
//  Meal+CoreDataClass.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//
//

import Foundation
import CoreData

@objc(Meal)
public class Meal: NSManagedObject, Decodable {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws { 
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            let id = try container.decode(String.self, forKey: .id)
            let name = try container.decode(String.self, forKey: .name)
            let image = try container.decodeIfPresent(String.self, forKey: .image)
            let instructions = try container.decode(String.self, forKey: .instructions)
            let category = try container.decode(Category.self, forKey: .category)
            let area = try container.decode(Area.self, forKey: .area)
            let ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
            let isArchived = try container.decode(Bool.self, forKey: .isArchived)
            
            
            let managedObjectContext = DataController.shared.managedObjectContext
            super.init(entity: .entity(forEntityName: "Meal", in: managedObjectContext)!, insertInto: managedObjectContext)
            
            self.id = id
            self.name = name
            self.image = image
            self.instructions = instructions
            self.category = category
            self.area = area
            self.ingredients = NSSet(array: ingredients)
            self.isArchived = isArchived
            
            
        } catch {
            let context = DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Failed to decode Meal entity. \(error.localizedDescription)",
                    underlyingError: error)
            throw DecodingError.dataCorrupted(context)
        }
    }
}

protocol AttributeType {
    associatedtype CoreDataType: CVarArg
    var value: CoreDataType { get }
}

extension String: AttributeType {
    var value: String { return self }
}

extension NSManagedObject: AttributeType {
    var value: NSManagedObject { return self }
}
