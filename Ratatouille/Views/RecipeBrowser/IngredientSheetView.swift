//
//  IngredientSheetView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 01/12/2023.
//

import SwiftUI

struct IngredientSheetView: View {
    @StateObject var viewModel: RecipeBrowserViewModel
    @State private var searchIngredient: String = ""
    @State private var shouldAlertError: Bool = false
    
    @State var filteredIngredients: [Ingredient] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<filteredIngredients.count, id: \.self) { index in
                    Group { // TODO: design UI
                        if let mappedIngredient = mapIngredient(filteredIngredients[index]) {
                            Text(mappedIngredient.name!)
                        } else {
                            Text(filteredIngredients[index].name!)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        searchIngredient = ""
                        
                        if let ingredientID = Int(filteredIngredients[index].id!), (1...608).contains(ingredientID) {
                            DispatchQueue.main.async {
                                viewModel.chosenIngredient = filteredIngredients[index].name!
                                viewModel.searchIngredientSheetPresented = false
                            }
                            Task { await viewModel.filterByIngredient() }
                        } else {
                            DispatchQueue.main.async {
                                viewModel.errorMessage = "Det er ikke mulig å søke etter oppskrifter basert på kategorier du selv har laget."
                                shouldAlertError = true
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitle("Ingredienser", displayMode: .inline)
            .searchable(text: $searchIngredient, prompt: "Søk etter ingrediens...")
            .onChange(of: searchIngredient) { newSearchIngredient in
                performSearch()
            }
            .alert("Feilmelding", isPresented: $shouldAlertError) {
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadIngredients()
                performSearch()
            }
        }
    }
    
    func performSearch() {
        Task {
            if searchIngredient.isEmpty {
                filteredIngredients = viewModel.ingredients
            } else {
                filteredIngredients = viewModel.ingredients.compactMap { mapIngredient($0)}
            }
        }
    }
    
    func mapIngredient(_ ingredient: Ingredient) -> Ingredient? {
        guard ingredient.name!.localizedCaseInsensitiveContains(searchIngredient) else {
            return nil
        }
        return ingredient
    }
}
