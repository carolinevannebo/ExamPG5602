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
    
    // Sheets
    @Published var isPresentingAddCategoryView: Bool = false
    @Published var isPresentingEditCategoryView: Bool = false
    
    // Errors
    @Published var shouldAlertError: Bool = false
    @Published var errorMessage: String = ""
    
    // Logic
    let loadCategoriesCommand = LoadCategoriesFromCDCommand()
    let saveCategoryCommand = AddNewCategoryCommand()
    let updateCategoryCommand = UpdateCategoryCommand()
    let archiveCategoryCommand = ArchiveCategoryCommand()
    
//    func checkAuthorization(category: Category) {
//        for i in 0..<14 {
//            if category.id == String(i+1) {
//                DispatchQueue.main.async {
//                    self.categoryAuthorized = false
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.categoryAuthorized = true
//                }
//            }
//        }
//    }
    
    enum ManageCategoriesViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case categoriesEmptyError
    }
}

struct ManageCategoriesView: View {
    @StateObject var viewModel = ManageCategoriesViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<viewModel.categories.count, id: \.self) { index in
                    ManageCategoryItem(
                        category: $viewModel.categories[index],
                        viewModel: viewModel
                    )
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
                Task { await viewModel.saveNewCategory(result: result) }
            }
        }
        .onAppear {
            Task { await viewModel.loadCategories() }
        }
        .refreshable {
            Task { await viewModel.loadCategories() }
        }
    }
}

struct ManageCategoryItem: View {
    @Binding var category: Category
    @StateObject var viewModel: ManageCategoriesViewModel
    @State var unAuthorized: Bool = false
    
    var body: some View {
        ZStack {
            CategoryCard(category: category)
            NavigationLink(destination:
                ScrollView {
                    CategoryDetailView(category: category)
                }
                .background(Color.myBackgroundColor)
                .toolbar {
                    CategoryToolBar(
                        viewModel: viewModel,
                        category: $category,
                        unAuthorized: unAuthorized
                    )
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
            DispatchQueue.main.async {
                if let categoryId = Int(category.id!), (1...14).contains(categoryId) {
                    self.unAuthorized = true
                } else {
                    self.unAuthorized = false
                }
            }
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
