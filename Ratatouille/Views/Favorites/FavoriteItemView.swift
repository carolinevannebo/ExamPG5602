//
//  FavoriteItemView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 30/11/2023.
//

import SwiftUI

class FavoriteItemViewModel: ObservableObject {
    @Published var meal: Meal
    @Published var offset: CGSize = .zero
    @Published var isDragging: Bool = false
    @Published var hasTappedArchive: Bool = false
    
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    let archiveCommand = ArchiveMealCommand()
    
    init(meal: Meal) {
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
                print("Recipe with name \(meal.name ) will be moved from archives")
                
                DispatchQueue.main.async { // dette må du dobbeltsjekke
                    self.meal.isArchived = false
                }
            }
        } catch {
            print("Unexpected error: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isShowingErrorAlert = true
            }
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
                    .foregroundColor(.myAccentColor)

                ArchiveIcon(viewModel: viewModel)
            }
            MealCardForFavorites(meal: viewModel.meal)
        }
        .padding(.horizontal)
        .alert("Feilmelding", isPresented: $viewModel.isShowingErrorAlert) {
        } message: {
            Text($viewModel.errorMessage.wrappedValue)
        }
    }
}

struct MealCardForFavorites: View {
    @StateObject var viewModel: FavoriteItemViewModel
    
    init(meal: Meal) {
        let favoriteItemViewModel = FavoriteItemViewModel(meal: meal)
        _viewModel = StateObject(wrappedValue: favoriteItemViewModel)
    }
    
    var body: some View {
        HStack {
            ImageWidget(url: viewModel.meal.image!)
            
            Spacer().frame(width: 20)
            
            MealCardContent(meal: viewModel.meal)
            
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.myPrimaryColor)
            )
            .offset(x: viewModel.offset.width, y: 0)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        viewModel.handleDragGesture(value: value)
                    }
                    .onEnded { value in
                        viewModel.handleDragEnd(value: value)
                    }
            )
            .onChange(of: viewModel.offset.width) { value in
                viewModel.isDragging = value != .zero
            }
    }
}

