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
                            for i in 0..<14 {
                                if viewModel.categories[index].id == String(i+1) {
                                    viewModel.chosenCategory = viewModel.categories[index].name
                                    Task { await viewModel.filterByCategory() }
                                } else {
                                    // TODO: error alert
                                    print("API cannot filter meal by category created by user")
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
