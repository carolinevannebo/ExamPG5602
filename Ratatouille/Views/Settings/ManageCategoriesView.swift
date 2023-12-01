//
//  ManageCategoriesView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 01/12/2023.
//

import Foundation
import SwiftUI

class ManageCategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    @Published var shouldAlertError: Bool = false
    @Published var isPresentingAddCategoryView: Bool = false
    
    @Published var currentError: Error? = nil
    
    let loadCategoriesCommand = LoadCategoriesFromCDCommand()
    
    func loadCategories() async {
        do {
            if let categories = await loadCategoriesCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.categories = categories
                }
            } else {
                throw ManageCategoriesViewModelError.categoriesEmptyError
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? ManageCategoriesViewModelError
            shouldAlertError = true
        }
    }
    
    enum ManageCategoriesViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case categoriesEmptyError
        
        var errorDescription: String? {
            switch self {
            case .failed(underlying: let underlying):
                return NSLocalizedString("Unable to establish error: \(underlying).", comment: "")
            case .categoriesEmptyError:
                return NSLocalizedString("Unable to load categories", comment: "")
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .categoriesEmptyError:
                return "Reload the page."
            default:
                return "Try again."
            }
        }
    }
}

struct ManageCategoriesView: View {
    @StateObject var viewModel = ManageCategoriesViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                
            } // list
            .padding(.top)
            .padding(.horizontal)
            .listStyle(.plain)
        } // navstack
        .navigationTitle("Rediger kategorier")
        .background(Color.myBackgroundColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isPresentingAddCategoryView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingAddCategoryView) {
            Text("Her skal du legge til ny kategori")
        }
        .onAppear {
            Task { await viewModel.loadCategories() }
        }
        .refreshable {
            Task { await viewModel.loadCategories() }
        }
        .errorAlert(error: $viewModel.currentError)
    }
}
