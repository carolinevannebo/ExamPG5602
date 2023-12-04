//
//  ArchiveAreaToolBar.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI

struct ArchiveAreaToolBar: ToolbarContent {
    @StateObject var viewModel: ArchiveViewModel
    @Binding var area: Area
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                // restore
                Task {
                    await viewModel.restoreArea(area: area)
                    await viewModel.loadAreasFromArchives()
                    dismiss()
                }
            } label: {
                Image(systemName: "arrow.up.bin.fill")
            }
            
            Button {
                // delete permanently
                Task {
                    await viewModel.deleteArea(area: area)
                    await viewModel.loadAreasFromArchives()
                    dismiss()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
}

struct AreaArchiveSheet: View {
    @StateObject var viewModel: ArchiveViewModel
    
    var body: some View {
        NavigationStack {
            Text("area archive sheet")
        }
    }
}

extension ArchiveViewModel {
    
    func loadAreasFromArchives() async {
        do {
            if let areas = await loadAreasCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.areas = areas
                    self.listId = UUID()
                }
            } else {
                throw ArchiveViewModelError.noAreasInArchives
            }
        } catch {
            print("Unexpected error when loading archived areas to View: \(error)")
        }
    }
    
    func restoreArea(area: Area) async {
        do {
            let result = await restoreAreaCommand.execute(input: area)
                
            switch result {
            case .success(let area):
                print("\(area.name) has been restored")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when restoring area from archives: \(error)")
        }
    }
    
    func deleteArea(area: Area) async {
        do {
            let result = await deleteAreaCommand.execute(input: area)
            
            switch result {
            case .success(_):
                print("Area was successfully deleted")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when deleting area permanently: \(error)")
        }
    }
}
