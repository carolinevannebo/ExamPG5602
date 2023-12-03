//
//  CategoryToolBar.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 02/12/2023.
//

import Foundation
import SwiftUI

struct CategoryToolBar: ToolbarContent {
    @StateObject var viewModel: ManageCategoriesViewModel
    @Binding var category: Category
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                // edit
                Task {
                    viewModel.isPresentingEditCategoryView = true
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
            
            Button {
                // archive
                Task {
                    await viewModel.archiveCategory(category: category)
                    await viewModel.loadCategories()
                    dismiss()
                }
            } label: {
                Image(systemName: "archivebox.fill")
            }
        }
    }
}

extension ManageCategoriesViewModel {
    func loadCategories() async {
        do {
            if let categories = await loadCategoriesCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.categories = categories
                }
            } else {
                throw ManageCategoriesViewModelError.categoriesEmptyError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? ManageCategoriesViewModelError
            shouldAlertError = true
        }
    }
    
    func saveNewCategory(result: Result<CategoryModel, Error>) async {
        switch result {
        case .success(let category):
            print("Category with name \(category.name) was passed")
            
            let saveToCDResult = await saveCategoryCommand.execute(input: category)
            
            switch saveToCDResult {
            case .success(_):
                print("Category was successfully passed and saved")
                
                DispatchQueue.main.async {
                    self.isPresentingAddCategoryView = false
                }
                
                await loadCategories()
                
            case .failure(let error):
                print("Category was passed, but not saved: \(error)")
            }
            
        case .failure(let error):
            print("Category could not be passed: \(error)")
        }
    }
    
    func updateCategory(result: Result<Category, Error>) async {
        switch result {
        case .success(let category):
            print("Category with name \(category.name) was passed")
            
            let updateToCDResult = await updateCategoryCommand.execute(input: category)
            
            switch updateToCDResult {
            case .success(_):
                print("Category was successfully passed and updated")
                
                DispatchQueue.main.async {
                    self.isPresentingAddCategoryView = false
                }
                
                await loadCategories()
                
            case .failure(let error):
                print("Category was passed, but not updated: \(error)")
            }
            
        case .failure(let error):
            print("Category could not be passed: \(error)")
        }
    }
    
    func archiveCategory(category: Category) async {
        do {
            let result = await archiveCategoryCommand.execute(input: category)
            
            switch result {
            case .success(_):
                print("successfully archived category")
                
                await loadCategories()
                
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? ManageCategoriesViewModelError
            shouldAlertError = true
        }
    }
}
