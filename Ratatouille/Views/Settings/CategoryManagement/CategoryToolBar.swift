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
    @State var category: Category
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                // edit
                Task {
                    print("kategori \(category.name) vil bli redigert")
                    viewModel.isPresentingEditCategoryView = true
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
            
            Button {
                // delete permanently MARK: nope, check the exam again
                Task {
//                    print("kategori \(category.name) med id \(category.id ?? "ukjent id") vil bli slettet permanent") // hvis den ikke har id 1-14
//                    let result = await viewModel.deleteCategoryCommand.execute(input: category)
                    
                    await viewModel.archiveCategory(category: category)
                    
//                    switch result {
//                    case .success(_):
//                        print("Category with name was deleted")
//                    case .failure(let error):
//                        print("Category could not be deleted: \(error)")
//                    }
                    
                    await viewModel.loadCategories()
                    dismiss()
                }
            } label: {
                Image(systemName: "archivebox.fill")
            }
        }
    }
}
