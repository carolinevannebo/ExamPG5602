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
