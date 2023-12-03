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
    @Published var isPresentingEditCategoryView: Bool = false
    
    @Published var currentError: Error? = nil
    @Published var categoryAuthorized: Bool = true
    
    let loadCategoriesCommand = LoadCategoriesFromCDCommand()
    let saveCategoryCommand = AddNewCategoryCommand()
    let updateCategoryCommand = UpdateCategoryCommand()
    let archiveCategoryCommand = ArchiveCategoryCommand()
    let deleteCategoryCommand = DeleteCategoryCommand()
    
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
    
    func saveNewCategory(result: Result<CategoryModel, Error>) async {
        switch result {
        case .success(let category):
            print("Category with name \(category.name) was passed")
            
            let saveToCDResult = await saveCategoryCommand.execute(input: category)
            
            switch saveToCDResult {
            case .success(_):
                print("Category was successfully passed and saved")
                await loadCategories()
                isPresentingAddCategoryView = false
                
            case .failure(let error):
                print("Category was passed, but not saved: \(error)")
            }
            
        case .failure(let error):
            print("Category could not be passed: \(error)")
        }
    }
    
    func updateCategory(result: Result<Category, Error>) async {
        switch result {
        case .success(let category):
            print("Category with name \(category.name) was passed")
            
            let updateToCDResult = await updateCategoryCommand.execute(input: category)
            
            switch updateToCDResult {
            case .success(_):
                print("Category was successfully passed and updated")
                await loadCategories()
                isPresentingEditCategoryView = false
            case .failure(let error):
                print("Category was passed, but not updated: \(error)")
            }
            
        case .failure(let error):
            print("Category could not be passed: \(error)")
        }
    }
    
    func archiveCategory(category: Category) async {
        do {
            let result = await archiveCategoryCommand.execute(input: category)
            
            switch result {
            case .success(_):
                print("successfully archived category")
                await loadCategories()
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            currentError = error as? ManageCategoriesViewModelError
            shouldAlertError = true
        }
    }
    
    func checkAuthorization(category: Category) {
        for i in 0..<14 {
            if category.id == String(i+1) {
                DispatchQueue.main.async {
                    self.categoryAuthorized = false
                }
            } else {
                DispatchQueue.main.async {
                    self.categoryAuthorized = true
                }
            }
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
                ForEach(0..<viewModel.categories.count, id: \.self) { index in
                    ManageCategoryItem(
                        category: viewModel.categories[index],
                        viewModel: viewModel,
                        categoryAuthorized: $viewModel.categoryAuthorized
                    )
                } // foreach
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
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
            AddCategoryView() { result in
                Task {
                    await viewModel.saveNewCategory(result: result)
                }
            }
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

struct ManageCategoryItem: View {
    @State var category: Category
    @StateObject var viewModel: ManageCategoriesViewModel
    @Binding var categoryAuthorized: Bool
    
    var body: some View {
        ZStack {
            CategoryCard(category: category)
            NavigationLink(destination:
                ScrollView {
                    CategoryDetailView(category: category)
                }
                .background(Color.myBackgroundColor)
                .toolbar {
                    if categoryAuthorized {
                        CategoryToolBar(viewModel: viewModel, category: category)
                    }
                }
                .sheet(isPresented: $viewModel.isPresentingEditCategoryView) {
                    EditCategoryView(category: category) { result in
                        Task { await viewModel.updateCategory(result: result) }
                    }
                }
            ) {
                EmptyView()
            }
            .opacity(0)
        }
        .onAppear {
            viewModel.checkAuthorization(category: category) // TODO: Need to fix that toolbar doesnt appear for default categories
        }
    }
}

struct CategoryCard: View {
    @State var category: Category
    
    var body: some View {
        ZStack (alignment: .leading) {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.myDiffusedColor)
                .shadow(radius: 2)
                .frame(height: 50)
                .opacity(0.9)
            HStack {
                Spacer().frame(width: 30)
                CircleImage(url: category.image ?? "", width: 65, height: 65, strokeColor: .clear, lineWidth: 0)
                
                Text(category.name)
                    .padding(.leading)
                    .font(.system(size: 17))
                    .foregroundColor(.myContrastColor)
            }
        }
    }
}
