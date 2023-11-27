//
//  MealCards.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 24/11/2023.
//

import Foundation
import SwiftUI

// TODO: refactor redundance

// This meal card takes in a meal from CoreData
struct MealCardForMeal: View {
    @StateObject var viewModel: FavoriteItemViewModel
    
    init(meal: Meal) {
        let favoriteItemViewModel = FavoriteItemViewModel(meal: meal)
        _viewModel = StateObject(wrappedValue: favoriteItemViewModel)
        //_viewModel = StateObject(wrappedValue: FavoriteItemViewModel(meal: meal)!)
    }
    
    var body: some View {
        HStack {
            ImageWidget(url: viewModel.meal.image!)
            
                Spacer().frame(width: 20)
                
                VStack (alignment: .leading) {
                    Text(viewModel.meal.name! )
                        .font(.system(size: 15, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.myContrastColor)
                    
                    Text("\(viewModel.meal.area?.name ?? "N/A") \((viewModel.meal.category?.name ?? "N/A"))")
                        .font(.callout)
                        .foregroundColor(.myAccentColor)
                    
                }
                .padding()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.myPrimaryColor)
            )
            // TODO: fix animations for this type of swipe
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

// This meal card takes in a meal from the api
struct MealCardForMealModel: View {
    @StateObject var viewModel: MealItemViewModel
        
    init(meal: MealModel) {
        let mealItemViewModel = MealItemViewModel(meal: meal)
        _viewModel = StateObject(wrappedValue: mealItemViewModel)
        //_viewModel = StateObject(wrappedValue: MealItemViewModel(meal: meal))
    }
    
    var body: some View {
        HStack {
            ImageWidget(url: viewModel.meal.image!)
               
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
                        .multilineTextAlignment(.leading)
                    
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

