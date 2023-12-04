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
    @Published var passingArea: Area?
    
    @Published var isPresentingAddAreaView: Bool = false
    @Published var isPresentingEditAreaView: Bool = false
    
    @Published var errorMessage: String = ""
    @Published var shouldAlertError: Bool = false
    @Published var areaAuthorized: Bool = true
    
    let loadAreasCommand = LoadAreasFromCDCommand()
    let saveAreaCommand = AddNewAreaCommand()
    let updateAreaCommand = UpdateAreaCommand()
    let archiveAreaCommand = ArchiveAreaCommand()
    
    enum ManageAreasViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case areasEmptyError
    }
}

struct ManageAreasView: View {
    @StateObject var viewModel = ManageAreasViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<viewModel.areas.count, id: \.self) { index in
                    
                    AreaTextBox(area: viewModel.areas[index], backgroundColor: .myDiffusedColor, textColor: .myContrastColor)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                viewModel.passingArea = viewModel.areas[index]
                                viewModel.isPresentingEditAreaView = true
                            }
                        }
                        .swipeActions {
                            Button {
                                Task {
                                    await viewModel.archiveArea(area: $viewModel.areas[index].wrappedValue)
                                }
                            } label: {
                                Image(systemName: "archivebox.fill")
                            }
                        }
                    
                } // foreach
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            } // list
            .padding(.top)
            .padding(.horizontal)
            .listStyle(.plain)
            .alert("Feilmelding", isPresented: $viewModel.shouldAlertError) {
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
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
            AddAreaView() { result in
                Task {
                    await viewModel.saveNewArea(result: result)
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingEditAreaView) {
            EditAreaView(area: viewModel.passingArea!) { result in
                Task {
                    await viewModel.updateArea(result: result)
                }
            }
        }
        .onAppear {
            Task { await viewModel.loadAreas() }
        }
        .refreshable {
            Task { await viewModel.loadAreas() }
        }
    }
}

extension ManageAreasViewModel {
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
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.shouldAlertError = true
            }
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
            DispatchQueue.main.async { // TODO: refaktorer til try/catch
                self.errorMessage = error.localizedDescription
                self.shouldAlertError = true
            }
        }
                
        case .failure(let error):
            print("Area could not be passed: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.shouldAlertError = true
            }
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
                DispatchQueue.main.async { // TODO: refaktorer
                    self.errorMessage = error.localizedDescription
                    self.shouldAlertError = true
                }
            }
            
        case .failure(let error):
            print("Area could not be passed: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.shouldAlertError = true
            }
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
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.shouldAlertError = true
            }
        }
    }
}
