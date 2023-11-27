//
//  RecipeBrowserView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 21/11/2023.
//

import SwiftUI

// TODO: rename to recipebrowser, create seperate view for the list itself
class RecipeBrowserViewModel: ObservableObject {
    // Inputs to search with
    @Published var input: String = ""
    @Published var chosenCategory: String = ""
    
    // Stored data to present
    @Published var meals: [MealModel] = []
    @Published var categories: [CategoryModel] = []
    
    // Reloads results
    @Published var searchId: UUID = UUID()
    
    // isPresented values for searching sheet
    @Published var searchAreaSheetPresented: Bool = false
    @Published var searchIngredientSheetPresented: Bool = false
    
    // Logic
    let searchCommand = SearchMealsCommand()
    let loadCategoriesCommand = LoadCategoriesCommand()
    let filterCommand = FilterByCategoriesCommand() // TODO: add loading stages
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true // TODO: this shouldnt be here, right?
    
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
                throw MealListViewModelError.mealsEmpty
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func filterByCategories() async {
        do {
            if let meals = await filterCommand.execute(input: chosenCategory) {
                DispatchQueue.main.async {
                    self.meals = meals
                    self.searchId = UUID()
                }
            } else {
                throw MealListViewModelError.filterError
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func loadCategories() async {
        do {
            if let categories = await loadCategoriesCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.categories = categories
                }
            } else {
                throw MealListViewModelError.categoriesEmpty
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    enum MealListViewModelError: Error {
        case failed(underlying: Error)
        case mealsEmpty
        case categoriesEmpty
        case filterError
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
                Text("her skal man søke i landområder")
                    .modifier(DarkModeViewModifier())
                    .presentationDetents([.medium, .large])
                    .presentationBackground(Color.myBackgroundColor.opacity(0.8))
            }
            .sheet(isPresented: $viewModel.searchIngredientSheetPresented) {
                // search ingredients
                Text("her skal man søke i ingredienser")
                    .modifier(DarkModeViewModifier())
                    .presentationDetents([.medium, .large])
                    .presentationBackground(Color.myBackgroundColor.opacity(0.8))
            }
            // --------------   REFACTOR REDUNDANCE ----------------------
            
        } // navStack
        .background(Color.myBackgroundColor)
        .environment(\.colorScheme, viewModel.isDarkMode ? .dark : .light)
        .onAppear {
            Task {
                await viewModel.loadCategories()
                await viewModel.searchMeals(isDemo: true)
            }
        }
        
    }
}

struct InputField: View {
    @StateObject var viewModel: RecipeBrowserViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .shadow(radius: 1)
                .foregroundColor(Color.myInputBgColor)
            
            HStack {
                TextField("",
                          text: $viewModel.input,
                          prompt: Text("Søk etter navn, bokstav, id...").foregroundColor(Color.myPlaceholderColor)
                ).onSubmit {
                    Task {
                        await viewModel.searchMeals(isDemo: false)
                    }
                }
                
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .frame(width: 17, height: 17)
            }
            .padding(20)
            .frame(minWidth: 100, minHeight: 40)
            .foregroundColor(Color.myInputTextColor)
        }
        .frame(height: 40)
        .padding()
    }
}

struct RecipeBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeBrowserView()
    }
}

