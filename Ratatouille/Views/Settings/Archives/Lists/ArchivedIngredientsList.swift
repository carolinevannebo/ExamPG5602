//
//  ArchivedIngredientsList.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

struct ArchivedIngredientsList: View {
    @StateObject var viewModel: ArchiveViewModel
    
    var body: some View {
        Section("Ingredienser") { // MARK: unpopulated atm
            ForEach(0..<viewModel.ingredients.count, id: \.self) { index in
                ZStack {
                    ArchiveListItemView(name: viewModel.ingredients[index].name!)
                }
            }
            .id(viewModel.listId)
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.clear)
        }
    }
}
