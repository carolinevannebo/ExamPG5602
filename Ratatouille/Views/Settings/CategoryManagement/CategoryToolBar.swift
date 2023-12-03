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
//    @State var category: Category
    @Binding var category: Category
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
