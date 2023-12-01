//
//  RecipeBrowserView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 21/11/2023.
//

import SwiftUI

class RecipeBrowserViewModel: ObservableObject {
    // Inputs to search with
    @Published var input: String = ""
    @Published var chosenArea: String = ""
    @Published var chosenCategory: String = ""
    @Published var chosenIngredient: String = ""
    
    // Stored data to present
    @Published var meals: [MealModel] = []
    @Published var areas: [Area] = []
    @Published var categories: [Category] = []
    @Published var ingredients: [Ingredient] = []
    
    // Reloads results
    @Published var searchId: UUID = UUID()
    
    // isPresented values for searching sheet
    @Published var searchAreaSheetPresented: Bool = false
    @Published var searchIngredientSheetPresented: Bool = false
    
    // Error alert
    @Published var shouldAlertError: Bool = false
    @Published var currentError: RecipeBrowserViewModelError? = nil
    
    // Logic
    let searchCommand = SearchMealsCommand()
    
    let loadAreasCommand = LoadAreasFromCDCommand()
    let loadCategoriesCommand = LoadCategoriesFromCDCommand()
    let loadIngredientsCommand = LoadIngredientsFromCDCommand()
    
    let filterByAreaCommand = FilterByAreaCommand()
    let filterByCategoryCommand = FilterByCategoryCommand() // TODO: add loading stages
    let filterByIngredientCommand = FilterByIngredientCommand()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    func searchMeals(isDemo: Bool) async {
        do {
            var mutableInput: String
            
            if isDemo {
                mutableInput = "A"
            } else {
                mutableInput = input
            }
            
            if let meals = await searchCommand.execute(input: mutableInput) {
                DispatchQueue.main.async {
                    self.meals = meals
                    self.searchId = UUID()
                }
            } else {
                throw RecipeBrowserViewModelError.mealsEmptyError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? RecipeBrowserViewModel.RecipeBrowserViewModelError
            shouldAlertError = true
        }
    }
    
    func loadAreas() async {
        do {
            if let areas = await loadAreasCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.areas = areas
                }
            } else {
                throw RecipeBrowserViewModelError.areasEmptyError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? RecipeBrowserViewModel.RecipeBrowserViewModelError
            shouldAlertError = true
        }
    }
    
    func loadCategories() async {
        do {
            if let categories = await loadCategoriesCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.categories = categories
                }
            } else {
                throw RecipeBrowserViewModelError.categoriesEmptyError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? RecipeBrowserViewModel.RecipeBrowserViewModelError
            shouldAlertError = true
        }
    }
    
    func loadIngredients() async {
        do {
            if let ingredients = await loadIngredientsCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.ingredients = ingredients
                }
            } else {
                throw RecipeBrowserViewModelError.ingredientsEmptyError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? RecipeBrowserViewModel.RecipeBrowserViewModelError
            shouldAlertError = true
        }
    }
    
    func filterByArea() async {
        do {
            if let meals = await filterByAreaCommand.execute(input: chosenArea) {
                DispatchQueue.main.async {
                    self.meals = meals
                    self.searchId = UUID()
                }
            } else {
                throw RecipeBrowserViewModelError.filterError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? RecipeBrowserViewModel.RecipeBrowserViewModelError
            shouldAlertError = true
        }
    }
    
    func filterByCategory() async {
        do {
            if let meals = await filterByCategoryCommand.execute(input: chosenCategory) {
                DispatchQueue.main.async {
                    self.meals = meals
                    self.searchId = UUID()
                }
            } else {
                throw RecipeBrowserViewModelError.filterError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? RecipeBrowserViewModel.RecipeBrowserViewModelError
            shouldAlertError = true
        }
    }
    
    func filterByIngredient() async {
        do {
            if let meals = await filterByIngredientCommand.execute(input: chosenIngredient) {
                DispatchQueue.main.async {
                    self.meals = meals
                    self.searchId = UUID()
                }
            } else {
                throw RecipeBrowserViewModelError.filterError
            }
        } catch {
            print("Unexpected error: \(error)")
            self.currentError = error as? RecipeBrowserViewModel.RecipeBrowserViewModelError
            shouldAlertError = true
        }
    }
    
    enum RecipeBrowserViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case mealsEmptyError
        case areasEmptyError
        case categoriesEmptyError
        case ingredientsEmptyError
        case filterError
        
        var errorDescription: String {
            switch self {
            case .failed(underlying: let underlying):
                return "Unable to establish error: \(underlying)."
            case .mealsEmptyError:
                return "No meals matching search. Please provide a valid input."
            case .areasEmptyError:
                return "Ratatouille was unable to load areas."
            case .categoriesEmptyError:
                return "Ratatouille was unable to load categories."
            case .ingredientsEmptyError:
                return "Ratatouille was unable to load ingredients."
            case .filterError:
                return "Ratatouille was unable to filter."
            }
        }
    }
}

struct RecipeBrowserView: View {
    @StateObject var viewModel = RecipeBrowserViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                InputField(viewModel: viewModel)
                
                ScrollView {
                    CategoryListView(viewModel: viewModel)
                    MealListView(viewModel: viewModel)
                }
            }
            .navigationTitle("Oppskrifter")
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.searchAreaSheetPresented = true
                    } label: {
                        Image(systemName: "flag.circle")
                            .foregroundColor(Color.myAccentColor)
                            .font(.system(size: 20))
                    }
                }
                
                ToolbarItem {
                    Button {
                        viewModel.searchIngredientSheetPresented = true
                    } label: {
                        Image(systemName: "leaf.circle")
                            .foregroundColor(Color.myAccentColor)
                            .font(.system(size: 20))
                    }
                }
            }
            // --------------   REFACTOR REDUNDANCE ----------------------
            .sheet(isPresented: $viewModel.searchAreaSheetPresented) {
                // search area
                AreaSheetView(viewModel: viewModel)
                    .modifier(DarkModeViewModifier())
                    .presentationDetents([.medium])
                    .presentationBackground(Color.myBackgroundColor.opacity(0.8))
            }
            .sheet(isPresented: $viewModel.searchIngredientSheetPresented) {
                // search ingredients
                IngredientSheetView(viewModel: viewModel)
                    .modifier(DarkModeViewModifier())
                    .presentationDetents([.medium, .large])
                    .presentationBackground(Color.myBackgroundColor.opacity(0.8))
            }
            // --------------   REFACTOR REDUNDANCE ----------------------
            .alert(isPresented: $viewModel.shouldAlertError, error: viewModel.currentError) { _ in
                Button("OK") {}
            } message: { error in
                Text(error.errorDescription)
            }
            
        } // navStack
        .background(Color.myBackgroundColor)
        .environment(\.colorScheme, viewModel.isDarkMode ? .dark : .light)
    }
}

struct InputField: View {
    @StateObject var viewModel: RecipeBrowserViewModel
    
    var body: some View {
        TextField("", text: $viewModel.input)
            .modifier(InputFieldViewModifier(viewModel: viewModel, inputType: .inputMeal))
            .frame(height: 40)
            .padding()
    }
}

struct RecipeBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeBrowserView()
    }
}

