//
//  MealItemView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import SwiftUI

class MealItemViewModel: ObservableObject {
    @Published var meal: Meal
    
    init(meal: Meal) {
        self.meal = meal
    }
    
    enum MealItemViewModelError: Error {
        case unreachableDemo
    }
}

struct MealItemView: View {
    @StateObject var viewModel: MealItemViewModel
        
    init(meal: Meal) {
        _viewModel = StateObject(wrappedValue: MealItemViewModel(meal: meal))
    }
    
    var body: some View {
        HStack {
            CircleImage(url: viewModel.meal.image!, width: 65, height: 65, strokeColor: Color.white, lineWidth: 0)
            Text(viewModel.meal.name ?? "N/A")
        }
    }
}

struct MealItemView_Previews: PreviewProvider {
    static var previews: some View {
        let demoMeal = Meal.demoMeal()
        MealItemView(meal: demoMeal)
    }
}
