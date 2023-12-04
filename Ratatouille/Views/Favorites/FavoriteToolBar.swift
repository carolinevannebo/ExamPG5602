//
//  FavoriteToolBar.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 04/12/2023.
//

import Foundation
import SwiftUI

struct FavoriteToolBar: ToolbarContent {
    @StateObject var viewModel: FavoritesViewModel
    @Binding var meal: Meal
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                // edit
                Task {
                    viewModel.isPresentingSheet = true
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
            
            Button {
                // archive
                Task {
                    await viewModel.archiveMeal(meal: meal)
                    dismiss()
                }
            } label: {
                Image(systemName: "archivebox.fill")
            }
        }
    }
}

extension FavoritesViewModel {
    func archiveMeal(meal: Meal) async {
        do {
            let result = await archiveCommand.execute(input: meal)
            
            switch result {
            case .success(_):
                print("Archiving success")
                
                await loadFavoriteMeals()
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when archiving from detailview \(error)")
        }
    }
}
