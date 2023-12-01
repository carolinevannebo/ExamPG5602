//
//  Favorites.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 22/11/2023.
//

import SwiftUI
import CoreData

class FavoritesViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var hasFavorites: Bool = false
    @Published var listId: UUID = UUID()
    
    let loadCommand = LoadFavoritesCommand()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    func loadFavoriteMeals() async {
        do {
            if let meals = await loadCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.meals = meals
                    self.listId = UUID()
                    
                    if !self.meals.isEmpty {
                        self.hasFavorites = true
                    } else {
                        self.hasFavorites = false
                    }
                }
            } else {
                throw FavoritesViewModelError.noFavorites
            }
        } catch {
            print("Unexpected error when loading favorites to View: \(error)")
        }
    }
    
    enum FavoritesViewModelError: Error {
        case noFavorites
    }
}

struct FavoritesView: View {
    @StateObject var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if viewModel.hasFavorites {
                    ScrollView {
                        ForEach(0..<viewModel.meals.count, id: \.self) { index in
                            NavigationLink {
                                MealDetailView(meal: viewModel.meals[index])
                            } label: {
                                FavoriteItemView(meal: viewModel.meals[index]).padding(.horizontal)
                            }
                        }.id(viewModel.listId)
                    }
                } else {
                    EmptyFavoritesView()
                }
            }
            .navigationTitle("Favoritter")
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .background(Color.myBackgroundColor)
        .environment(\.colorScheme, viewModel.isDarkMode ? .dark : .light)
        .onAppear {
            Task { await viewModel.loadFavoriteMeals() }
        }
        .refreshable {
            Task { await viewModel.loadFavoriteMeals() }
        }
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack {
            Spacer().frame(maxWidth: .infinity)
            
            Image(systemName: "square.stack.3d.up.slash")
                .foregroundColor(.myPrimaryColor)
                .font(.system(size: 40))
            
            Text("Ingen matoppskrifter")
                .foregroundColor(.mySecondaryColor)
            
            Spacer().frame(maxWidth: .infinity)
        }
    }
}
