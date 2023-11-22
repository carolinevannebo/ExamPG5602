//
//  Ingredient+CoreDataProperties.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 20/11/2023.
//
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var id: String?
    @NSManaged public var information: String?
    @NSManaged public var name: String?
}

extension Ingredient : Identifiable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case information
    }
}
