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
        Section("Ingredienser") {
            ForEach(0..<viewModel.ingredients.count, id: \.self) { index in
                ArchiveListItemView(name: viewModel.ingredients[index].name!)
                    .onTapGesture {
                        DispatchQueue.main.async { // her kan den klage på multi-threading
                            viewModel.passingIngredient = viewModel.ingredients[index]
                            viewModel.selectSheet = .ingredient
                            viewModel.isSheetPresented = true
                        }
                    }
                
            }
            .id(viewModel.listId)
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.clear)
        }
    }
}

