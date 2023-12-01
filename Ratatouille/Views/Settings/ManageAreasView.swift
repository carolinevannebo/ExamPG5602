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
    
    @Published var currentError: Error? = nil
    
    let loadAreasCommand = LoadAreasFromCDCommand()
    
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
                    ZStack {
                        AreaTextBox(area: viewModel.areas[index], backgroundColor: .myDiffusedColor, textColor: .myContrastColor)
                        NavigationLink(destination: Text(viewModel.areas[index].name.value)) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                }
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
        .onAppear {
            Task { await viewModel.loadAreas() }
        }
        .refreshable {
            Task { await viewModel.loadAreas() }
        }
        .errorAlert(error: $viewModel.currentError)
    }
}
