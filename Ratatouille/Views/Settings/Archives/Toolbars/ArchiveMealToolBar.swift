//
//  ArchiveMealToolBar.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

struct ArchiveMealToolBar: ToolbarContent {
    @StateObject var viewModel = ArchiveViewModel()
    @State var meal: Meal
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                // restore
                Task {
                    viewModel.isSheetPresented = false
                    await viewModel.restoreMeal(meal: meal)
                    await viewModel.loadMealsFromArchive()
                    dismiss()
                }
            } label: {
                Image(systemName: "arrow.up.bin.fill")
            }
            
            Button {
                // delete permanently
                Task {
                    viewModel.isSheetPresented = false
                    await viewModel.deleteMeal(meal: meal)
                    await viewModel.loadMealsFromArchive()
                    dismiss()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
}

extension ArchiveViewModel {
    func loadMealsFromArchive() async {
        do {
            if let meals = await loadMealsCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.meals = meals
                    self.listId = UUID()
                }
            } else {
                throw ArchiveViewModelError.noMealsInArchives
            }
            
        } catch {
            print("Unexpected error when loading archived meals to View: \(error)")
        }
    }
    
    func restoreMeal(meal: Meal) async {
        do {
            let result = await restoreMealCommand.execute(input: meal)
            
            switch result {
            case .success(let meal):
                print("\(meal.name) has been restored")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when restoring meal from archives: \(error)")
        }
    }
    
    func deleteMeal(meal: Meal) async {
        do {
            let result = await deleteMealCommand.execute(input: meal)
            
            switch result {
            case .success(_):
                print("Meal was successfully deleted")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when deleting meal permanently: \(error)")
        }
    }
}
