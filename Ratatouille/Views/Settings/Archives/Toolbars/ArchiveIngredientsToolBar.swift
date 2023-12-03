//
//  ArchiveIngredientsToolBar.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

struct ArchiveIngredientToolBar: ToolbarContent {
    @StateObject var viewModel: ArchiveViewModel
    @Binding var ingredient: Ingredient
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                // restore
                Task {
                    await viewModel.restoreIngredient(ingredient: ingredient)
                    await viewModel.loadIngredientsFromArchives()
                    dismiss()
                }
            } label: {
                Image(systemName: "arrow.up.bin.fill")
            }
            
            Button {
                // delete permanently
                Task {
                    await viewModel.deleteIngredient(ingredient: ingredient)
                    await viewModel.loadIngredientsFromArchives()
                    dismiss()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
}

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
