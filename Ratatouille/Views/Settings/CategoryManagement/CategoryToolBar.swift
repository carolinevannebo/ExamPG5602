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
