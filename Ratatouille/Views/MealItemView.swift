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
    
    let favoritesLogic = SaveFavorite()
    
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
                let result = await favoritesLogic.execute(input: self.meal)
                
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
                    
                    HStack {
                        Spacer()
                        if (viewModel.hasTappedHeart) {
                            Image(systemName: "heart.fill")
                                .onTapGesture {
                                    viewModel.hasTappedHeart = false
                                }
                        } else {
                            Image(systemName: "heart")
                                .onTapGesture {
                                    Task {
                                        viewModel.hasTappedHeart = true
                                        let result = await viewModel.favoritesLogic.execute(input: viewModel.meal)
                                        print(result)
                                    }
                                }
                        }
                    }
                    .foregroundColor(.mySwipeIconColor)
                    .font(.system(size: 35))
                    .padding(.trailing, 30)
                }
            }
            MealCard(meal: viewModel.meal)
        }
        .padding(.horizontal)
    }
}

struct MealCard: View {
    @StateObject var viewModel: MealItemViewModel
        
    init(meal: MealModel) {
        _viewModel = StateObject(wrappedValue: MealItemViewModel(meal: meal))
    }
    
    var body: some View {
        HStack {
            MealImageWidget(viewModel: viewModel)
               
            HStack {
                Spacer().frame(width: 20)
                
                VStack (alignment: .leading) {
                    Text(viewModel.meal.name )
                        .font(.system(size: 15, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.myContrastColor)
                    
                    Text("\(viewModel.meal.area?.name ?? "N/A") \((viewModel.meal.category?.name ?? "N/A"))")
                        .font(.callout)
                        .foregroundColor(.myAccentColor)
                    
                }
                .padding()
                Spacer()
            } // Testing HStack
            
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
        } // HStack
    }
}

struct MealImageWidget: View {
    @StateObject var viewModel: MealItemViewModel
    
    var body: some View {
        ZStack (alignment: .leading) {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.mySecondaryColor)
                
            CircleImage(url: viewModel.meal.image!, width: 65, height: 65, strokeColor: Color.white, lineWidth: 0)
        }.frame(width: 90)
    }
}

//struct MealItemView_Previews: PreviewProvider {
//    @Environment(\.managedObjectContext) private var managedObjectContext
//
//    static var previews: some View {
//        let demoMeal = Meal.demoMeal(managedObjectContext: managedObjectContext)
//        MealItemView(meal: demoMeal)
//    }
//}
