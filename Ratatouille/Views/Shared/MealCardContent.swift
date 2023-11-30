//
//  MealCardContent.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 24/11/2023.
//

import Foundation
import SwiftUI

struct MealCardContent<MealType: MealRepresentable>: View {
    @State var meal: MealType
    
    var body: some View {
        HStack {
            Spacer().frame(width: 20)
            
            VStack (alignment: .leading) {
                Text(meal.name )
                    .font(.system(size: 15, weight: .semibold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.myContrastColor)
                
                Text("\(meal.area?.name ?? "N/A") \((meal.category?.name ?? "N/A"))")
                    .font(.callout)
                    .foregroundColor(.myAccentColor)
                    .multilineTextAlignment(.leading)
                
            }
            .padding()
            Spacer()
        }
    }
}
