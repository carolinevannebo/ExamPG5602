//
//  MealListView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import SwiftUI

class MealListViewModel: ObservableObject {
    @Published var input = ""
    @Published var meals: [Meal] = []
    let searchLogic = SearchMeals()
    
    func searchMeals() async {
        do {
            if let meals = await searchLogic.execute(input: input) {
                DispatchQueue.main.async {
                    self.meals = meals
                }
            } else {
                print("You should have a backup json") // TODO: backup json
                throw MealListViewModelError.mealsEmpty
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    enum MealListViewModelError: Error {
        case failed(underlying: Error)
        case mealsEmpty
    }
}

struct MealListView: View {
    @StateObject var viewModel = MealListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search meals", text: $viewModel.input, onCommit: {
                    Task {
                        await viewModel.searchMeals()
                    }
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                List {
                    ForEach(viewModel.meals) { meal in
                        NavigationLink {
                            Text(meal.name ?? "N/A")
                        } label: {
                            Text(meal.name ?? "N/A")
                        }
                    }
                }
            }
        } // navView, onAppear can apply here
    }
}

struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        MealListView()
    }
}

