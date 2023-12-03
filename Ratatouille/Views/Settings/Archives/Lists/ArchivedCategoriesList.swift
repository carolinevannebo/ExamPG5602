//
//  ArchivedCategoriesList.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

struct ArchivedCategoriesList: View {
    @StateObject var viewModel: ArchiveViewModel
    
    var body: some View {
        Section("Kategorier") {
            ForEach(0..<viewModel.categories.count, id: \.self) { index in
                ZStack {
                    ArchiveListItemView(name: viewModel.categories[index].name)
                    
                    NavigationLink(
                        destination: {
                            CategoryDetailView(category: viewModel.categories[index])
                                .toolbar {
                                    ArchiveCategoryToolBar(
                                        viewModel: viewModel,
                                        category: $viewModel.categories[index]
                                    )
                                }
                        }
                    ) { EmptyView() }
                        .opacity(0)
                }
            }
            .id(viewModel.listId)
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.clear)
        }
    }
}
