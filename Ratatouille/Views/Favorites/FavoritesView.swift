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
    
    @Published var isPresentingEditSheet: Bool = false
    @Published var isPresentingAddSheet: Bool = false
    
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    let loadCommand = LoadFavoritesCommand()
    let archiveCommand = ArchiveMealCommand() // TODO: refaktorer så favoriteitem bruker denne
    let updateCommand = UpdateMealCommand()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
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
                    FavoritesListContent(viewModel: viewModel)
                        .sheet(isPresented: $viewModel.isPresentingAddSheet) {
                            Text("add new meal")
                        }
//                    ScrollView {
//                        ForEach(0..<viewModel.meals.count, id: \.self) { index in
//                            NavigationLink {
//                                MealDetailView(meal: viewModel.meals[index])
//                                    .refreshable {
//                                        Task { await viewModel.loadFavoriteMeals() }
//                                    }
//                                    .toolbar {
//                                        FavoriteToolBar(
//                                            viewModel: viewModel,
//                                            meal: $viewModel.meals[index]
//                                        )
//                                    }
//                                    .sheet(isPresented: $viewModel.isPresentingEditSheet) {
//                                        EditMealView(meal: viewModel.meals[index]) { result in
//                                            Task { await viewModel.updateMeal(result: result)}
//                                        }
//                                    }
//                                    .sheet(isPresented: $viewModel.isPresentingAddSheet) {
//                                        print("add new meal")
//                                    }
//                            } label: {
//                                FavoriteItemView(meal: viewModel.meals[index]).padding(.horizontal)
//                            }
//                        }.id(viewModel.listId)
//                    }
                } else {
                    EmptyFavoritesView()
                }
            }
            .navigationTitle("Favoritter")
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
            .alert("Feilmelding", isPresented: $viewModel.isShowingErrorAlert) {
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        DispatchQueue.main.async {
                            viewModel.isPresentingAddSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
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

struct FavoritesListContent: View {
    @StateObject var viewModel: FavoritesViewModel
    
    var body: some View {
        ScrollView {
            ForEach(0..<viewModel.meals.count, id: \.self) { index in
                NavigationLink {
                    MealDetailView(meal: viewModel.meals[index])
                        .refreshable {
                            Task { await viewModel.loadFavoriteMeals() }
                        }
                        .toolbar {
                            FavoriteToolBar(
                                viewModel: viewModel,
                                meal: $viewModel.meals[index]
                            )
                        }
                        .sheet(isPresented: $viewModel.isPresentingEditSheet) {
                            EditMealView(meal: viewModel.meals[index]) { result in
                                Task { await viewModel.updateMeal(result: result)}
                            }
                        }
                } label: {
                    FavoriteItemView(meal: viewModel.meals[index]).padding(.horizontal)
                }
            }.id(viewModel.listId)
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

extension FavoritesViewModel {
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
    
    func updateMeal(result: Result<Meal, Error>) async {
            switch result {
            case .success(let meal):
                print("Meal with name \(meal.name) was passed")
                
                let updateToCDResult = await updateCommand.execute(input: meal)
                
                switch updateToCDResult {
                case .success(_):
                    print("Meal was successfully passed and updated")
                    
                    DispatchQueue.main.async {
                        self.isPresentingEditSheet = false
                    }
                    
                    await loadFavoriteMeals()
                    
                case .failure(let error): //TODO: dette kan refaktoreres til do/catch
                    print("Meal was passed, but not updated: \(error)")
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.isShowingErrorAlert = true
                    }
                }
                
            case .failure(let error):
                print("Meal could not be passed: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isShowingErrorAlert = true
                }
            }
        }
}
