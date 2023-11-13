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
    
    enum CodingKeys: CodingKey {
        case strArea
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .strArea)
        
        let dataController = DataController.shared
        let managedObjectContext = dataController.container.viewContext
        super.init(entity: .entity(forEntityName: "Area", in: managedObjectContext)!, insertInto: managedObjectContext)
        
        self.name = name
    }
}

struct AreasWrapper: Decodable {
    let meals: [Area] // Has to be meals, to recognize the field in the API
}
