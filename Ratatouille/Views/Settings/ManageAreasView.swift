//
//  ManageAreasView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 01/12/2023.
//

import Foundation
import SwiftUI

class ManageAreasViewModel: ObservableObject {
    @Published var areas: [Area] = []
    
    @Published var shouldAlertError: Bool = false
    @Published var isPresentingAddAreaView: Bool = false
    @Published var isPresentingEditAreaView: Bool = false
    
    @Published var currentError: Error? = nil
    @Published var areaAuthorized: Bool = true
    
    let loadAreasCommand = LoadAreasFromCDCommand()
    let saveAreaCommand = AddNewAreaCommand()
    let updateAreaCommand = UpdateAreaCommand()
    let archiveAreaCommand = ArchiveAreaCommand()
    
    func loadAreas() async {
        do {
            if let areas = await loadAreasCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.areas = areas
                }
            } else {
                throw ManageAreasViewModelError.areasEmptyError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? ManageAreasViewModelError
            shouldAlertError = true
        }
    }
    
    func saveNewArea(result: Result<AreaModel, Error>) async {
        switch result {
        case .success(let area):
            print("Area with name \(area.name) was passed")
                
            let saveToCDResult = await saveAreaCommand.execute(input: area)
                
        switch saveToCDResult {
        case .success(_):
            print("Area was successfully passed and saved")
                    
            DispatchQueue.main.async {
                self.isPresentingAddAreaView = false
            }
            
            await loadAreas()
                    
        case .failure(let error):
            print("Area was passed, but not saved: \(error)")
        }
                
        case .failure(let error):
            print("Area could not be passed: \(error)")
        }
    }
    
    func updateArea(result: Result<Area, Error>) async {
        switch result {
        case .success(let area):
            print("Area with name \(area.name) was passed")
            
            let updateToCDResult = await updateAreaCommand.execute(input: area)
                
            switch updateToCDResult {
            case .success(_):
                print("Area was successfully passed and updated")
                
                DispatchQueue.main.async {
                    self.isPresentingEditAreaView = false
                }
                
                await loadAreas()
                
            case .failure(let error):
                print("Area was passed, but not updated: \(error)")
            }
            
        case .failure(let error):
            print("Area could not be passed: \(error)")
        }
    }
    
    func archiveArea(area: Area) async {
        do {
            let result = await archiveAreaCommand.execute(input: area)
                
            switch result {
            case .success(_):
                print("Successfully archived area")
                await loadAreas()
                
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? ManageAreasViewModelError // TODO: burde sjekke alle set error, kanskje sett på main thread
            shouldAlertError = true
        }
    }
    
    enum ManageAreasViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case areasEmptyError
        
        var errorDescription: String? {
            switch self {
            case .failed(underlying: let underlying):
                return NSLocalizedString("Unable to establish error: \(underlying).", comment: "")
            case .areasEmptyError:
                return NSLocalizedString("Unable to load areas", comment: "")
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .areasEmptyError:
                return "Reload the page."
            default:
                return "Try again."
            }
        }
    }
}

struct ManageAreasView: View {
    @StateObject var viewModel = ManageAreasViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<viewModel.areas.count, id: \.self) { index in
                    AreaTextBox(area: viewModel.areas[index], backgroundColor: .myDiffusedColor, textColor: .myContrastColor)
                    //TODO: sett editsheet til true ontap
                        .onTapGesture {
                            Task {
                                viewModel.isPresentingEditAreaView = true
                            }
                        }
                } // foreach
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            } // list
            .padding(.top)
            .padding(.horizontal)
            .listStyle(.plain)
        } // navstack
        .navigationTitle("Rediger landområder")
        .background(Color.myBackgroundColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isPresentingAddAreaView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingAddAreaView) {
            Text("Her skal du legge til nytt landområde")
        }
        .sheet(isPresented: $viewModel.isPresentingEditAreaView) {
            Text("Her skal du redigere landområde")
        }
        .onAppear {
            Task { await viewModel.loadAreas() }
        }
        .refreshable {
            Task { await viewModel.loadAreas() }
        }
        .errorAlert(error: $viewModel.currentError)
    }
}

