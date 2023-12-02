//
//  MealItemView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 21/11/2023.
//

import SwiftUI

class MealItemViewModel: ObservableObject {
    @Published var meal: MealModel
    @Published var offset: CGSize = .zero
    @Published var isDragging: Bool = false
    @Published var hasTappedHeart: Bool = false
    
    let saveCommand = SaveFavoriteCommand()
    let archiveCommand = ArchiveMealCommand()
    
    init(meal: MealModel) {
        self.meal = meal
    }
    
    
    enum MealItemViewModelError: Error {
        case unreachableDemo
        case saveFailed
    }
    
    func handleTappedHeart() async {
        do {
            if hasTappedHeart {
                let result = await saveCommand.execute(input: self.meal)
                
                switch result {
                case .success(let favorite):
                    print("Saving \(String(describing: favorite.name)) succeeded")
                    
                    DispatchQueue.main.async {
                        self.meal.isFavorite = true
                    }
                    
                case .failure(let error):
                    throw error
                }
            } else {
                let result = await archiveCommand.execute(input: self.meal)
                
                switch result {
                case .success(let archive):
                    print("Archive has \(archive.meals?.count ?? 0) records")
                case .failure(let error):
                    throw error
                }
                
                DispatchQueue.main.async { // TODO: redundant?
                    self.meal.isFavorite = false
                    
                }
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func handleDragGesture(value: DragGesture.Value) {
        if value.translation.width < 0 {
            offset.width = value.translation.width
        }

        let maxTranslation = UIScreen.main.bounds.width - 290 // adjusted to stop at parents width
        offset.width = max(-maxTranslation, min(offset.width, 0))
    }
        
    func handleDragEnd(value: DragGesture.Value) {
        if isDragging {
            // Do not reset the offset to zero if it's actively being dragged
            isDragging = false
        } else {
            let halfWidth = UIScreen.main.bounds.width / 2
            //let maxTranslation = UIScreen.main.bounds.width - 290
            
            if offset.width < -halfWidth {
                // Swipe to the left
                withAnimation {
                    offset.width = -UIScreen.main.bounds.width
                }
            } else if offset.width > halfWidth {
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

struct MealItemView: View {
    @StateObject var viewModel: MealItemViewModel

    init(meal: MealModel) {
        let mealItemViewModel = MealItemViewModel(meal: meal)
        _viewModel = StateObject(wrappedValue: mealItemViewModel)
    }

    var body: some View {
        ZStack {
            HStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.myPrimaryColor)

                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .foregroundColor(.myAccentColor) //my primarycolor

                    HeartIcon(viewModel: viewModel)
                }
            }
            MealCardForRecipeBrowser(viewModel: viewModel)
        }
        .padding(.horizontal)
    }
}

struct MealCardForRecipeBrowser: View {
    @StateObject var viewModel: MealItemViewModel
    
    var body: some View {
        HStack {
            ImageWidget(url: viewModel.meal.image!)
               
            MealCardContent(meal: viewModel.meal)
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
}
