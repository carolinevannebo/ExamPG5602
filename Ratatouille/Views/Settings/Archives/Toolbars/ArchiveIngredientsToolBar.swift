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
                    viewModel.isSheetPresented = false
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
                    viewModel.isSheetPresented = false
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

struct IngredientArchiveSheet: View { // TODO: style om du får tid
    @StateObject var viewModel: ArchiveViewModel
    @State var ingredient: Ingredient
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                Text(ingredient.name ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding()
                
                Spacer()
                
                HStack {
                    Text(ingredient.information ?? "")
                    
                    Spacer()
                    if ingredient.image != nil {
                        Image(uiImage: UIImage(data: Data(base64Encoded: ingredient.image!)!)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding(.horizontal)
            .toolbar {
                ArchiveIngredientToolBar(viewModel: viewModel, ingredient: $ingredient)
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
