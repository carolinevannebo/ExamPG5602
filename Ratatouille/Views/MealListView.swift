//
//  MealListView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import SwiftUI

class MealListViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var chosenCategory: String = ""
    @Published var meals: [MealModel] = []
    @Published var categories: [CategoryModel] = []
    @Published var searchId: UUID = UUID()
    
    // TODO: you want to have one command, and set that command to different values based on events
    let searchCommand = SearchMealsCommand()
    let loadCategoriesCommand = LoadCategoriesCommand()
    let filterCommand = FilterByCategoriesCommand() // TODO: add loading stages
    
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

struct MealListView: View {
    @StateObject var viewModel = MealListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search meals", text: $viewModel.input, onCommit: {
                    Task {
                        await viewModel.searchMeals(isDemo: false)
                    }
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                ScrollView {
                    // category widgets
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<viewModel.categories.count, id: \.self) { index in
                                CategoryItemView(category: viewModel.categories[index])
                                    .onTapGesture {
                                        viewModel.chosenCategory = viewModel.categories[index].name
                                        Task {
                                            await viewModel.filterByCategories()
                                        }
                                    }
                            }
                        }
                    }
                    .frame(height: 140)
                    .padding()
                
                    VStack {
                        ForEach(0..<viewModel.meals.count, id: \.self) { index in
                            NavigationLink {
                                Text(viewModel.meals[index].name ) // TODO: DetailView
                            } label: {
                                MealItemView(meal: viewModel.meals[index])//.shadow(radius: 10)
                                    .padding(.horizontal)
                            }
                        }.id(viewModel.searchId)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Oppskrifter")
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
            
        } // navView, onAppear can apply here
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

struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        MealListView()
    }
}

