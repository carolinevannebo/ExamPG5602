//
//  Favorites.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import SwiftUI
import CoreData

class FavoritesViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var hasTappedArchive: Bool = false
    
    let loadFavorites = LoadFavorites()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    func loadFavoriteMeals() async {
        do {
            if let meals = await loadFavorites.execute(input: ()) {
                DispatchQueue.main.async {
                    self.meals = meals
                }
            } else {
                throw FavoritesViewModelError.noFavorites
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    enum FavoritesViewModelError: Error {
        case noFavorites
    }
}

class FavoriteItemViewModel: ObservableObject {
    @Published var meal: Meal
    init?(meal: Meal) {
        self.meal = meal
    }
}

struct FavoritesView: View {
    @StateObject var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(0..<viewModel.meals.count, id: \.self) { index in
                    NavigationLink {
                        Text(viewModel.meals[index].name ?? "unknown").foregroundColor(.myContrastColor) // TODO: DetailView
                    } label: {
                        FavoriteItemView(meal: viewModel.meals[index]).padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Favoritter")
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .background(Color.myBackgroundColor)
        .environment(\.colorScheme, viewModel.isDarkMode ? .dark : .light)
        .onAppear {
            Task {
                await viewModel.loadFavoriteMeals()
            }
        }
    }
}

struct FavoriteItemView: View {
    @StateObject var viewModel: FavoriteItemViewModel

    init(meal: Meal) {
        _viewModel = StateObject(wrappedValue: FavoriteItemViewModel(meal: meal)!)
    }

    var body: some View {
        ZStack {
            HStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.myPrimaryColor)

                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .foregroundColor(.myAccentColor) //my primarycolor

                    ArchiveIcon(viewModel: FavoritesViewModel())
                }
            }
            MealCardForMeal(meal: viewModel.meal)
        }
        .padding(.horizontal)
    }
}
