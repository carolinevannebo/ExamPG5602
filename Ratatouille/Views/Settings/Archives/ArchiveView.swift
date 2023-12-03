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
    
    @Published var hasArchive: Bool = false
    @Published var listId: UUID?
    
    let loadMealsCommand = LoadMealsFromArchivesCommand()
    let restoreMealCommand = RestoreMealCommand()
    let deleteMealCommand = DeleteMealCommand()
    
    //TODO: area commands
    
    let loadCategoriesCommand = LoadCategoriesFromArchivesCommand()
    let restoreCategoryCommand = RestoreCategoryCommand()
    let deleteCategoryCommand = DeleteCategoryCommand()
    
    //TODO: ingredient commands
    
    func loadMealsFromArchive() async {
        do {
            if let meals = await loadMealsCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.meals = meals
                    self.listId = UUID()
                    
                    if !meals.isEmpty {
                        self.hasArchive = true
                    } else {
                        self.hasArchive = false
                    }
                }
            } else {
                throw ArchiveViewModelError.noMealsInArchives
            }
            
        } catch {
            print("Unexpected error when loading archived meals to View: \(error)")
        }
    }
    
    func restoreMeal(meal: Meal) async {
        do {
            let result = await restoreMealCommand.execute(input: meal)
            
            switch result {
            case .success(let meal):
                print("\(meal.name) has been restored")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when restoring meal from archives: \(error)")
        }
    }
    
    func deleteMeal(meal: Meal) async {
        do {
            let result = await deleteMealCommand.execute(input: meal)
            
            switch result {
            case .success(_):
                print("Meal was successfully deleted")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when deleting meal permanently: \(error)")
        }
    }
    
    func loadCategoriesFromArchives() async {
        do {
            if let categories = await loadCategoriesCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.categories = categories
                    self.listId = UUID()
                    
                    if !categories.isEmpty {
                        self.hasArchive = true // TODO: you should remove this boolean from archive view
                    } else {
                        self.hasArchive = false
                    }
                }
            } else {
                throw ArchiveViewModelError.noCategoriesInArchives
            }
        } catch {
            print("Unexpected error when loading archived categories to View: \(error)")
        }
    }
    
    func restoreCategory(category: Category) async {
        do {
            let result = await restoreCategoryCommand.execute(input: category)
            
            switch result {
            case .success(let category):
                print("\(category.name) has been restored")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when restoring category from archives: \(error)")
        }
    }
    
    func deleteCategory(category: Category) async {
        do {
            let result = await deleteCategoryCommand.execute(input: category)
            
            switch result {
            case .success(_):
                print("Category was successfully deleted")
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when deleting category permanently: \(error)")
        }
    }
    
    enum ArchiveViewModelError: Error {
        case noMealsInArchives
        case noCategoriesInArchives
    }
}

struct ArchiveView: View {
    @StateObject var viewModel = ArchiveViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ArchivedAreasList(viewModel: viewModel) // MARK: unpopulated
                    ArchivedCategoriesList(viewModel: viewModel)
                    ArchivedMealsList(viewModel: viewModel)
                    ArchivedIngredientsList(viewModel: viewModel) // MARK: unpopulated
                }
                .padding(.top)
                .padding(.horizontal)
                .listStyle(.plain)
            }
            .navigationTitle("Arkiv")
            .background(Color.myBackgroundColor)
        }
        .onAppear {
            Task {
                // TODO: await viewModel.loadAreasFromArchives()
                await viewModel.loadCategoriesFromArchives()
                await viewModel.loadMealsFromArchive()
                // TODO: await viewModel.loadIngredientsFromArchives()
            }
        }
        .refreshable {
            Task {
                // TODO: await viewModel.loadAreasFromArchives()
                await viewModel.loadCategoriesFromArchives()
                await viewModel.loadMealsFromArchive()
                // TODO: await viewModel.loadIngredientsFromArchives()
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
