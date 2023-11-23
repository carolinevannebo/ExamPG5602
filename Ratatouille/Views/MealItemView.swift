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
            //.frame(width: 150)
            .padding()
            
            Spacer()
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
