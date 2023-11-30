//
//  MealRepresentable.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 30/11/2023.
//

import Foundation

protocol MealRepresentable { // TODO: mulig du trenger setters?
    associatedtype AreaType: AreaRepresentable
    associatedtype CategoryType: CategoryRepresentable
    associatedtype IngredientType: IngredientRepresentable
    associatedtype IngredientsCollection//: Collection where IngredientsCollection.Element == IngredientType
    
    var id: String { get set }
    var name: String { get set }
    var image: String? { get set }
    var instructions: String? { get set }
    var area: AreaType? { get set }
    var category: CategoryType? { get set }
    var ingredients: IngredientsCollection? { get set }
}

protocol AreaRepresentable {
    var name: String { get set }
}

protocol CategoryRepresentable {
    var id: String? { get set }
    var name: String { get set }
    var image: String? { get set }
    var information: String? { get set }
}

protocol IngredientRepresentable {
    var id: String? { get set }
    var name: String { get set }
    var information: String? { get set }
}
