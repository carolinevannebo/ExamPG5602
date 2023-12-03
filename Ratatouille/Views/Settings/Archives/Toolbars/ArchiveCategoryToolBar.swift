//
//  ArchiveCategoryToolBar.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

struct ArchiveCategoryToolBar: ToolbarContent {
    @StateObject var viewModel: ArchiveViewModel
    @Binding var category: Category
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                // restore
                Task {
                    await viewModel.restoreCategory(category: category)
                    await viewModel.loadCategoriesFromArchives()
                    dismiss()
                }
            } label: {
                Image(systemName: "arrow.up.bin.fill")
            }
            
            Button {
                // delete permanently
                Task {
                    await viewModel.deleteCategory(category: category)
                    await viewModel.loadCategoriesFromArchives()
                    dismiss()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
}

extension ArchiveViewModel {
    func loadCategoriesFromArchives() async {
        do {
            if let categories = await loadCategoriesCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.categories = categories
                    self.listId = UUID()
                }
            } else {
                throw ArchiveViewModelError.noCategoriesInArchives
            }
        } catch {
            print("Unexpected error when loading archived categories to View: \(error)")
        }
    }
    
    func restoreCategory(category: Category) async {
        do {
            let result = await restoreCategoryCommand.execute(input: category)
            
            switch result {
            case .success(let category):
                print("\(category.name) has been restored")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when restoring category from archives: \(error)")
        }
    }
    
    func deleteCategory(category: Category) async {
        do {
            let result = await deleteCategoryCommand.execute(input: category)
            
            switch result {
            case .success(_):
                print("Category was successfully deleted")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when deleting category permanently: \(error)")
        }
    }
}
