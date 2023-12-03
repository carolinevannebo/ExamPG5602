//
//  ArchivedMealsList.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

struct ArchivedMealsList: View {
    @StateObject var viewModel: ArchiveViewModel
    
    var body: some View {
        Section("Måltider") {
            ForEach(0..<viewModel.meals.count, id: \.self) { index in
                ZStack {
                    ArchiveListItemView(name: viewModel.meals[index].name)
                    
                    NavigationLink(
                        destination: {
                            MealDetailView(meal: viewModel.meals[index])
                                .toolbar {
                                    ArchiveMealToolBar(
                                        viewModel: viewModel,
                                        meal: viewModel.meals[index]
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
