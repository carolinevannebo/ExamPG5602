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

class FavoriteItemViewModel: ObservableObject {
    @Published var meal: Meal
    @Published var offset: CGSize = .zero
    @Published var isDragging: Bool = false
    @Published var hasTappedArchive: Bool = false
    
    // TODO: declare archive logic
    let archiveCommand = ArchiveMealCommand()
    
    init(meal: Meal) { // tok bort ?
        self.meal = meal
    }
    
    func handleTappedArchive() async {
        do {
            if hasTappedArchive {
                let result = await archiveCommand.execute(input: self.meal)
                
                switch result {
                case .success(let archive):
                    print("Archived \(self.meal.name ), archive has \(archive.meals?.count ?? 0) records")
                    
                    DispatchQueue.main.async {
                        self.meal.isArchived = true
                    }
                    // testvariant 1
                    await FavoritesViewModel().loadFavoriteMeals()
                case .failure(let error):
                    throw error
                }
            } else {
                // TODO: set isArchived to false
                print("Recipe with name \(meal.name ) will be moved from archives")
                
                DispatchQueue.main.async {
                    self.meal.isArchived = false
                }
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func handleDragGesture(value: DragGesture.Value) {
        if value.translation.width > 0 {
            offset.width = value.translation.width
        }

        let maxTranslation = UIScreen.main.bounds.width - 290 // TODO: adjust
        offset.width = min(maxTranslation, max(offset.width, 0))
    }
    
    func handleDragEnd(value: DragGesture.Value) {
        if isDragging {
            // Do not reset the offset to zero if it's actively being dragged
            isDragging = false
        } else {
            let halfWidth = UIScreen.main.bounds.width / 2

            if offset.width > halfWidth {
                // Swipe to the right
                withAnimation {
                    offset.width = 0
                }
            } else {
                // Snap back to the original position
                withAnimation {
                    offset = .zero
                }
            }
        }
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
                                Text(viewModel.meals[index].name ).foregroundColor(.myContrastColor) // TODO: DetailView
                            } label: {
                                FavoriteItemView(meal: viewModel.meals[index]).padding(.horizontal)
                            }
                        }.id(viewModel.listId)
                    }
                } else {
                    Spacer().frame(maxWidth: .infinity)
                    
                    Image(systemName: "square.stack.3d.up.slash")
                        .foregroundColor(.myPrimaryColor)
                        .font(.system(size: 40))
                    
                    Text("Ingen matoppskrifter")
                        .foregroundColor(.mySecondaryColor)
                    
                    Spacer().frame(maxWidth: .infinity)
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

struct FavoriteItemView: View {
    @StateObject var viewModel: FavoriteItemViewModel

    init(meal: Meal) {
        let favoriteItemViewModel = FavoriteItemViewModel(meal: meal)
        _viewModel = StateObject(wrappedValue: favoriteItemViewModel)
    }

    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.myAccentColor) //my primarycolor

                ArchiveIcon(viewModel: viewModel)
            }
            MealCardForMeal(meal: viewModel.meal)
        }
        .padding(.horizontal)
    }
}
