//
//  MealListView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import SwiftUI

class MealListViewModel: ObservableObject {
    @Published var input = ""
    @Published var meals: [MealModel] = []
    @Published var hasSearched: Bool = false
    let searchLogic = SearchMeals()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    func searchMeals(isDemo: Bool) async {
        do {
            var mutableInput: String
            
            if isDemo {
                mutableInput = "A"
            } else {
                mutableInput = input
            }
            
            if let meals = await searchLogic.execute(input: mutableInput) {
                DispatchQueue.main.async {
                    self.hasSearched = true
                    self.meals = meals // TODO: BUG - dersom man toggler tema, tilbakestilles søket
                }
            } else {
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
        NavigationStack {
            VStack {
                TextField("Search meals", text: $viewModel.input, onCommit: {
                    Task {
                        await viewModel.searchMeals(isDemo: false)
                    }
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // category widgets
                
                ScrollView {
                    ForEach(0..<viewModel.meals.count, id: \.self) { index in
                        NavigationLink {
                            Text(viewModel.meals[index].name ) // TODO: DetailView
                        } label: {
                            MealItemView(meal: viewModel.meals[index])//.shadow(radius: 10)
                            .padding(.horizontal)
                        }
                    }
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

