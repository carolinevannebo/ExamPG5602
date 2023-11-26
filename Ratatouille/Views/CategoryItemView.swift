//
//  CategoryItemView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 24/11/2023.
//

import SwiftUI

class CategoryItemViewModel: ObservableObject {
    @Published var category: CategoryModel
    
    init(category: CategoryModel) {
        self.category = category
    }
}

struct CategoryItemView: View {
    @StateObject var viewModel: CategoryItemViewModel

    init(category: CategoryModel) {
        _viewModel = StateObject(wrappedValue: CategoryItemViewModel(category: category))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.myDiffusedColor)
            
            VStack (alignment: .center) {
                CircleImage(url: viewModel.category.image!, width: 65, height: 65, strokeColor: Color.white, lineWidth: 0).padding()
                Text(viewModel.category.name)
                    .foregroundColor(.myContrastColor)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .padding()
            }
            //.frame(width: 110)
        }
        .frame(width: 110)
    }
}

