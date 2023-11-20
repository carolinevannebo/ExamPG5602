//
//  Measurement+CoreDataClass.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 20/11/2023.
//
//

import Foundation
import CoreData

@objc(Measurement)
public class Measurement: NSManagedObject {

    enum CodingKeys: CodingKey {
        case amount
        case ingredient
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let amount = try container.decode(String.self, forKey: .amount)
        let ingredient = try container.decodeIfPresent(Ingredient.self, forKey: .ingredient)
        
        let dataController = DataController.shared
        let managedObjectContext = dataController.container.viewContext
        
        super.init(entity: .entity(forEntityName: "Measurement", in: managedObjectContext)!, insertInto: managedObjectContext)
        
        self.amount = amount
        self.ingredient = ingredient
    }
}
