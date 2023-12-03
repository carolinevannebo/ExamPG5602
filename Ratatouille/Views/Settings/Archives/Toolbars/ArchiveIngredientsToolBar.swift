//
//  ArchiveIngredientsToolBar.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

//TODO: toolbar

extension ArchiveViewModel {
    func loadIngredientsFromArchives() async {
        do {
            if let ingredients = await loadIngredientsCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.ingredients = ingredients
                    self.listId = UUID()
                }
            } else {
                throw ArchiveViewModelError.noIngredientsInArchives
            }
        } catch {
            print("Unexpected error when loading archived ingredients to View: \(error)")
        }
    }
    
    func restoreIngredient(ingredient: Ingredient) async {
        do {
            let result = await restoreIngredientCommand.execute(input: ingredient)
                
            switch result {
            case .success(let ingredient):
                print("\(ingredient.name ?? "empty name for some reason?") has been restored")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when restoring ingredient from archives: \(error)")
        }
    }
    
    func deleteIngredient(ingredient: Ingredient) async {
            do {
                let result = await deleteIngredientCommand.execute(input: ingredient)
                
                switch result {
                case .success(_):
                    print("Ingredient was successfully deleted")
                case .failure(let error):
                    throw error
                }
            } catch {
                print("Unexpected error when deleting ingredient permanently: \(error)")
            }
        }
}
