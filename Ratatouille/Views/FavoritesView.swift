//
//  Favorites.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import SwiftUI

class FavoritesViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    
//    let favoritesLogic = LoadFavorites()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
//    func loadFavoriteMeals() async {
//        do {
//            if let meals = await favoritesLogic.execute(input: ()) {
//                DispatchQueue.main.async {
//                    self.meals = meals
//                }
//            } else {
//                throw FavoritesViewModelError.noFavorites
//            }
//        } catch {
//            print("Unexpected error: \(error)")
//        }
//    }
    
    enum FavoritesViewModelError: Error {
        case noFavorites
    }
}

struct FavoritesView: View {
    @StateObject var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
//                ForEach(viewModel.meals) { meal in
//                    NavigationLink {
//                        Text(meal.name ) // TODO: DetailView
//                    } label: {
//                        MealItemView(meal: viewModel.meal)
//                        .padding(.horizontal)
//                    }
//                }
            }
            .navigationTitle("Favoritter")
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .background(Color.myBackgroundColor)
        .environment(\.colorScheme, viewModel.isDarkMode ? .dark : .light)
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
