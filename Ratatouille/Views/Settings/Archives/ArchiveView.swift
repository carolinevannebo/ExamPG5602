//
//  ArchiveView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 27/11/2023.
//

import SwiftUI

class ArchiveViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var areas: [Area] = []
    @Published var categories: [Category] = []
    @Published var ingredients: [Ingredient] = []
    
    @Published var listId: UUID?
    @Published var isSheetPresented: Bool = false
    @Published var selectSheet: ArchiveSheetType? = nil
    
    @Published var passingIngredient: Ingredient?
    @Published var passingArea: Area?
    
    @Published var shouldAlertError: Bool = false
    @Published var errorMessage: String = ""
    
    // For readability logic has been placed in extensions in toolbar files
    let loadMealsCommand = LoadMealsFromArchivesCommand()
    let restoreMealCommand = RestoreMealCommand()
    let deleteMealCommand = DeleteMealCommand()
    
    let loadAreasCommand = LoadAreasFromArchivesCommand()
    let restoreAreaCommand = RestoreAreaCommand()
    let deleteAreaCommand = DeleteAreaCommand()
    
    let loadCategoriesCommand = LoadCategoriesFromArchivesCommand()
    let restoreCategoryCommand = RestoreCategoryCommand()
    let deleteCategoryCommand = DeleteCategoryCommand()
    
    let loadIngredientsCommand = LoadIngredientsFromArchivesCommand()
    let restoreIngredientCommand = RestoreIngredientCommand()
    let deleteIngredientCommand = DeleteIngredientCommand()
    
    enum ArchiveViewModelError: Error {
        case noMealsInArchives
        case noAreasInArchives
        case noCategoriesInArchives
        case noIngredientsInArchives
    }
    
    enum ArchiveSheetType: Identifiable {
        case area
        case ingredient
        
        var id: String {
            switch self {
            case .area:
                return "area"
            case .ingredient:
                return "ingredient"
            }
        }
    }
}

struct ArchiveView: View {
    @StateObject var viewModel = ArchiveViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ArchivedAreasList(viewModel: viewModel) // MARK: unpopulated atm
                    ArchivedCategoriesList(viewModel: viewModel)
                    ArchivedMealsList(viewModel: viewModel)
                    ArchivedIngredientsList(viewModel: viewModel)
                }
                .padding(.top)
                .padding(.horizontal)
                .listStyle(.plain)
                .alert("Feilmelding", isPresented: $viewModel.shouldAlertError) {
                } message: {
                    Text(viewModel.errorMessage)
                }
                
            }
            .navigationTitle("Arkiv")
            .background(Color.myBackgroundColor)
            .sheet(isPresented: $viewModel.isSheetPresented) {
                if let sheetType = viewModel.selectSheet {
                    viewModel.sheet(for: sheetType)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadAreasFromArchives()
                await viewModel.loadCategoriesFromArchives()
                await viewModel.loadMealsFromArchive()
                await viewModel.loadIngredientsFromArchives()
            }
        }
        .refreshable {
            Task {
                await viewModel.loadAreasFromArchives()
                await viewModel.loadCategoriesFromArchives()
                await viewModel.loadMealsFromArchive()
                await viewModel.loadIngredientsFromArchives()
            }
        }
    }
}

struct ArchiveListItemView: View {
    @State var name: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.myAlternativeBgColor)
            HStack {
                Text(name)
                    .font(.system(size: 17))
                    .padding(.leading, 30)
            }
            .foregroundColor(.myAlternativeTextColor)
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

struct IngredientArchiveSheet: View {
    @StateObject var viewModel: ArchiveViewModel
    @State var ingredient: Ingredient
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("ingredient archive sheet")
            }
        }
        .toolbar {
            ArchiveIngredientToolBar(viewModel: viewModel, ingredient: $ingredient)
        }
    }
}

// now unused
struct EmptyArchiveView: View {
    var body: some View {
        VStack {
            Spacer().frame(maxWidth: .infinity)
            
            Image(systemName: "square.stack.3d.up.slash")
                .foregroundColor(.myPrimaryColor)
                .font(.system(size: 40))
            
            Text("Tomt arkiv")
                .foregroundColor(.mySecondaryColor)
            
            Spacer().frame(maxWidth: .infinity)
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}

extension ArchiveViewModel { // TODO: refaktorer samme i recipebrowser sheets
    func sheet(for sheetType: ArchiveSheetType) -> some View {
        switch sheetType {
        case .area:
            return AnyView(AreaArchiveSheet(viewModel: self))
        case .ingredient:
            return AnyView(IngredientArchiveSheet(viewModel: self, ingredient: self.passingIngredient!))
        }
    }
}
