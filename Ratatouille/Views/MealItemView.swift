//
//  MealItemView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import SwiftUI

class MealItemViewModel: ObservableObject {
    @Published var meal: MealModel
    @Published var offset: CGSize = .zero
    @Published var isDragging: Bool = false
    @Published var hasTappedHeart: Bool = false
    
    let saveFavorite = SaveFavorite()
    
    init(meal: MealModel) {
        self.meal = meal
    }
    
    enum MealItemViewModelError: Error {
        case unreachableDemo
        case saveFailed
    }
    
    func handleTappedHeart() async {
        if hasTappedHeart {
            do {
                let result = await saveFavorite.execute(input: self.meal)
                
                switch result {
                case .success(let favorite):
                    print("Saving \(String(describing: favorite.name)) succeeded")
                case .failure(let error):
                    throw error
                }
                
            } catch {
                print("Unexpected error: \(error)")
            }
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
        _viewModel = StateObject(wrappedValue: MealItemViewModel(meal: meal))
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
            MealCardForMealModel(meal: viewModel.meal)
        }
        .padding(.horizontal)
    }
}
