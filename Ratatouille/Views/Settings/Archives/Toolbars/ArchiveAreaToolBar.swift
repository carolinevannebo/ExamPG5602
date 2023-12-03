//
//  ArchiveAreaToolBar.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation

//TODO: toolbar

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
