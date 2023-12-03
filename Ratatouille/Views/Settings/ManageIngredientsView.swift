//
//  ManageIngredientsView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

class ManageIngredientsViewModel: ObservableObject {
    @Published var ingredients: [Ingredient] = []
    
    @Published var shouldAlertError: Bool = false
    @Published var isPresentingAddIngredientView: Bool = false
    @Published var isPresentingEditIngredientView: Bool = false
    
    @Published var currentError: Error? = nil
    @Published var ingredientAuthorized: Bool = true
    
    let loadIngredientsCommand = LoadIngredientsFromCDCommand()
    let saveIngredientCommand = AddNewIngredientCommand()
    let updateIngredientCommand = UpdateIngredientCommand()
    let archiveIngredientCommand = ArchiveIngredientCommand()
    
    enum ManageIngredientsViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case ingredientsEmptyError
        
        var errorDescription: String? {
            switch self {
            case .failed(underlying: let underlying):
                return NSLocalizedString("Unable to establish error: \(underlying).", comment: "")
            case .ingredientsEmptyError:
                return NSLocalizedString("Unable to load ingredient", comment: "")
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .ingredientsEmptyError:
                return "Reload the page."
            default:
                return "Try again."
            }
        }
    }
}

struct ManageIngredientsView: View {
    @StateObject var viewModel = ManageIngredientsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<viewModel.ingredients.count, id: \.self) { index in
                    Text(viewModel.ingredients[index].name ?? "ukjent navn?") //MARK: midlertidig
                        .onTapGesture {
                            Task {
                                viewModel.isPresentingEditIngredientView = true
                            }
                        }
                } // foreach
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            } // list
            .padding(.top)
            .padding(.horizontal)
            .listStyle(.plain)
        } // navstack
        .navigationTitle("Rediger ingredienser")
        .background(Color.myBackgroundColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isPresentingAddIngredientView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingAddIngredientView) {
            Text("Her skal du legge til ny ingrediens")
        }
        .sheet(isPresented: $viewModel.isPresentingEditIngredientView) {
            Text("Her skal du redigere ingrediens")
        }
        .onAppear {
            Task { await viewModel.loadIngredient() }
        }
        .refreshable {
            Task { await viewModel.loadIngredient() }
        }
        .errorAlert(error: $viewModel.currentError)
    }
}

extension ManageIngredientsViewModel {
    func loadIngredient() async {
        do {
            if let ingredients = await loadIngredientsCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.ingredients = ingredients
                }
            } else {
                throw ManageIngredientsViewModelError.ingredientsEmptyError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? ManageIngredientsViewModelError
            shouldAlertError = true
        }
    }
    
    func saveNewIngredient(result: Result<IngredientModel, Error>) async {
        switch result {
        case .success(let ingredient):
            print("Ingredient with name \(ingredient.name ?? "unknown name?") was passed")
                
            let saveToCDResult = await saveIngredientCommand.execute(input: ingredient)
                
        switch saveToCDResult {
        case .success(_):
            print("Ingredient was successfully passed and saved")
                    
            DispatchQueue.main.async {
                self.isPresentingAddIngredientView = false
            }
            
            await loadIngredient()
                    
        case .failure(let error):
            print("Ingredient was passed, but not saved: \(error)")
        }
                
        case .failure(let error):
            print("Ingredient could not be passed: \(error)")
        }
    }
    
    func updateIngredient(result: Result<Ingredient, Error>) async {
        switch result {
        case .success(let ingredient):
            print("Ingredient with name \(ingredient.name ?? "unknown name?") was passed")
            
            let updateToCDResult = await updateIngredientCommand.execute(input: ingredient)
                
            switch updateToCDResult {
            case .success(_):
                print("Ingredient was successfully passed and updated")
                
                DispatchQueue.main.async {
                    self.isPresentingEditIngredientView = false
                }
                
                await loadIngredient()
                
            case .failure(let error):
                print("Ingredient was passed, but not updated: \(error)")
            }
            
        case .failure(let error):
            print("Ingredient could not be passed: \(error)")
        }
    }
    
    func archiveIngredient(ingredient: Ingredient) async {
        do {
            let result = await archiveIngredientCommand.execute(input: ingredient)
                
            switch result {
            case .success(_):
                print("Successfully archived ingredient")
                await loadIngredient()
                
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? ManageIngredientsViewModelError // TODO: burde sjekke alle set error, kanskje sett på main thread
            shouldAlertError = true
        }
    }
}
