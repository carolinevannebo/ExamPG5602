//
//  Area+CoreDataClass.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//
//

import Foundation
import CoreData

@objc(Area)
public class Area: NSManagedObject, Decodable {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let id = try container.decodeIfPresent(String.self, forKey: .id)
        
        let managedObjectContext = DataController.shared.managedObjectContext
        
        super.init(entity: .entity(forEntityName: "Area", in: managedObjectContext)!, insertInto: managedObjectContext)
        
        self.name = name
        self.id = id
    }
}
