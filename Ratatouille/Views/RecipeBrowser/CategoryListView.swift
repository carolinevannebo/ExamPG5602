//
//  CategoryListView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 27/11/2023.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject var viewModel: RecipeBrowserViewModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<viewModel.categories.count, id: \.self) { index in
                    CategoryItemView(category: viewModel.categories[index])
                        .onTapGesture {
                            
                            if let categoryId = Int(viewModel.categories[index].id!), (1...14).contains(categoryId) {
                                DispatchQueue.main.async {
                                    viewModel.chosenCategory = viewModel.categories[index].name
                                }
                                Task { await viewModel.filterByCategory() }
                            } else {
                                DispatchQueue.main.async {
                                    viewModel.errorMessage = "Det er ikke mulig å søke etter oppskrifter basert på kategorier du selv har laget."
                                    viewModel.shouldAlertError = true
                                }
                            }
                        }
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            Task { await viewModel.loadCategories() }
        }
    }
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView(viewModel: RecipeBrowserViewModel())
    }
}
