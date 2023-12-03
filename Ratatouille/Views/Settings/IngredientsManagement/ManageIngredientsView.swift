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
    
    // Sheets for add/edit
    @Published var isPresentingAddIngredientView: Bool = false
    @Published var isPresentingEditIngredientView: Bool = false
    
    // Error handling
    @Published var currentError: Error? = nil
    @Published var shouldAlertError: Bool = false
    @Published var ingredientAuthorized: Bool = true
    
    // Searching the long list of ingredients for usability
    @Published var searchIngredient: String = ""
    @Published var filteredIngredients: [Ingredient] = []
    @Published var chosenIngredient: Ingredient?
    
    // Logic used, functions located in extension at the bottom of this file
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

struct ManageIngredientItem: View {
    @State var name: String
    @State var image: String?
    
    var body: some View {
        HStack {
            Text(name).padding(.horizontal)
            Spacer()
            
            if image != nil {
                Image(uiImage: UIImage(data: Data(base64Encoded: image!)!)!)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 25)
    }
}

struct ManageIngredientsListContent: View {
    @StateObject var viewModel: ManageIngredientsViewModel
    
    var body: some View {
        ForEach(0..<viewModel.filteredIngredients.count, id: \.self) { index in
            Group {
                if let mappedIngredient = viewModel.mapIngredient(viewModel.filteredIngredients[index]) {
                    ManageIngredientItem(
                        name: mappedIngredient.name!,
                        image: mappedIngredient.image
                    )
                } else {
                    ManageIngredientItem(
                        name: $viewModel.filteredIngredients[index].wrappedValue.name!,
                        image: $viewModel.filteredIngredients[index].wrappedValue.image
                    )
                }
            }
            .listRowBackground(Color.clear)
            .onTapGesture {
                Task {
                    viewModel.searchIngredient = ""
                    viewModel.chosenIngredient = viewModel.filteredIngredients[index]
                    viewModel.isPresentingEditIngredientView = true
                }
            }
            .swipeActions {
                Button {
                    Task {
                        await viewModel.archiveIngredient(ingredient: $viewModel.filteredIngredients[index].wrappedValue)
                    }
                } label: {
                    Image(systemName: "archivebox.fill")
                }
            }
            
        } // foreach
    }
}

struct ManageIngredientsView: View {
    @StateObject var viewModel = ManageIngredientsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ManageIngredientsListContent(viewModel: viewModel)
            } // list
            .padding(.top)
            .padding(.horizontal)
            .listStyle(.plain)
            .searchable(text: $viewModel.searchIngredient, prompt: "Søk etter ingrediens...")
            .onChange(of: viewModel.searchIngredient) { newSearchIngredient in
                viewModel.performSearch()
            }
        } // navstack
        .navigationTitle("Rediger ingredienser")
        .background(Color.myBackgroundColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isPresentingAddIngredientView = true // TODO: skal denne være i main thread?
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingAddIngredientView) {
            AddIngredientView() { result in
                Task {
                    await viewModel.saveNewIngredient(result: result)
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingEditIngredientView) {
            Text("Her skal du redigere ingrediens med navn \((viewModel.chosenIngredient! as Ingredient).name!)")
        }
        .onAppear {
            Task {
                await viewModel.loadIngredient()
                viewModel.performSearch()
            }
        }
        .refreshable {
            Task {
                await viewModel.loadIngredient()
                viewModel.performSearch()
            }
        }
        .errorAlert(error: $viewModel.currentError)
    }
}

extension ManageIngredientsViewModel {
    func performSearch() {
        Task {
            if searchIngredient.isEmpty {
                self.filteredIngredients = ingredients
            } else {
                self.filteredIngredients = ingredients.compactMap { mapIngredient($0)}
            }
        }
    }
        
    func mapIngredient(_ ingredient: Ingredient) -> Ingredient? {
        guard ingredient.name!.localizedCaseInsensitiveContains(searchIngredient) else {
            return nil
        }
        return ingredient
    }
    
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
            DispatchQueue.main.async {
                self.currentError = error as? ManageIngredientsViewModelError
                self.shouldAlertError = true
            }
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
            DispatchQueue.main.async {
                self.currentError = error as? ManageIngredientsViewModelError // TODO: burde sjekke alle set error, kanskje sett på main thread
                self.shouldAlertError = true
            }
        }
    }
}
