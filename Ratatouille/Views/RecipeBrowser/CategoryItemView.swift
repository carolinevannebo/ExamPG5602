//
//  CategoryItemView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 24/11/2023.
//

import SwiftUI

struct CategoryItemView: View {
    @State var category: CategoryModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.myDiffusedColor)
                .shadow(radius: 1)
            
            VStack (alignment: .center) {
                CircleImage(url: category.image!, width: 65, height: 65, strokeColor: Color.white, lineWidth: 0)
                Text(category.name)
                    .foregroundColor(.myContrastColor)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
            }
            .frame(height: 110)
            .padding()
        }
        .frame(width: 110)
    }
}

