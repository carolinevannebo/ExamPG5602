//
//  MealItemView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import SwiftUI

class MealItemViewModel: ObservableObject {
    @Published var meal: MealModel
    
    init(meal: MealModel) {
        self.meal = meal
    }
    
    enum MealItemViewModelError: Error {
        case unreachableDemo
    }
}

struct MealItemView: View {
    @StateObject var viewModel: MealItemViewModel
        
    init(meal: MealModel) {
        _viewModel = StateObject(wrappedValue: MealItemViewModel(meal: meal))
    }
    
    var body: some View {
        HStack {
            ZStack (alignment: .leading) {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.mySecondaryColor)
                    
                CircleImage(url: viewModel.meal.image!, width: 65, height: 65, strokeColor: Color.white, lineWidth: 0)
            }.frame(width: 90)
                
            Spacer()
                
            VStack {
                Text(viewModel.meal.name ).foregroundColor(.myAccentColor).font(.callout)
                Text(viewModel.meal.category?.name ?? "N/A").foregroundColor(.myContrastColor)
                Text(viewModel.meal.area?.name ?? "N/A").foregroundColor(.myContrastColor)
            }
        }
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
