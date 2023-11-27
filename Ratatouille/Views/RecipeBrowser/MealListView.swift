//
//  MealListView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 27/11/2023.
//

import SwiftUI

struct MealListView: View {
    @StateObject var viewModel: RecipeBrowserViewModel
    
    var body: some View {
        VStack {
            ForEach(0..<viewModel.meals.count, id: \.self) { index in
                NavigationLink {
                    MealDetailView(meal: viewModel.meals[index])
                } label: {
                    MealItemView(meal: viewModel.meals[index])
                }
            }.id(viewModel.searchId)
        }
        .padding(.vertical)
    }
}

struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        MealListView(viewModel: RecipeBrowserViewModel())
    }
}
