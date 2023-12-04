//
//  ArchivedAreasListt.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

struct ArchivedAreasList: View {
    @StateObject var viewModel: ArchiveViewModel
    
    var body: some View {
        Section("Landområder") { // MARK: unpopulated atm
            ForEach(0..<viewModel.areas.count, id: \.self) { index in
                ZStack {
                    ArchiveListItemView(name: viewModel.areas[index].name)
                        .onTapGesture { // MARK: må du i dispatchqueue main?
                            viewModel.selectSheet = .area
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
