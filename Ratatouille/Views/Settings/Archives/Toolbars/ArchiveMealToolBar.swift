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
