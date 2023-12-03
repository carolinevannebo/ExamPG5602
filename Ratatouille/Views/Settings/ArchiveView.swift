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
    // TODO: restore
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
//                if viewModel.hasArchive {
                    List {
                        Section("Landområder") { // MARK: unpopulated atm
                            ForEach(0..<viewModel.areas.count, id: \.self) { index in
                                ZStack {
                                    ArchiveListItemView(name: viewModel.areas[index].name)
                                }
                            }
                            .id(viewModel.listId)
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(Color.clear)
                        }
                        
                        Section("Kategorier") {
                            ForEach(0..<viewModel.categories.count, id: \.self) { index in
                                ZStack {
                                    ArchiveListItemView(name: viewModel.categories[index].name)
                                }
                            }
                            .id(viewModel.listId)
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(Color.clear)
                        }
                        
                        Section("Måltider") {
                            ForEach(0..<viewModel.meals.count, id: \.self) { index in
                                ZStack {
//                                    ArchiveItemView(meal: viewModel.meals[index])
                                    ArchiveListItemView(name: viewModel.meals[index].name)
                                    
                                    NavigationLink(
                                        destination: {
                                            MealDetailView(meal: viewModel.meals[index])
                                                .toolbar {
                                                    ArchiveMealToolBar(viewModel: viewModel, meal: viewModel.meals[index])
                                                }
                                        }
                                    ) { EmptyView() }
                                        .opacity(0)
                                }
                            }
                            .id(viewModel.listId)
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(Color.clear)
                        }
                        
                        Section("Ingredienser") { // MARK: unpopulated atm
                            ForEach(0..<viewModel.ingredients.count, id: \.self) { index in
                                ZStack {
                                    ArchiveListItemView(name: viewModel.ingredients[index].name)
                                }
                            }
                            .id(viewModel.listId)
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(Color.clear)
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    .listStyle(.plain)
//                } else {
//                    EmptyArchiveView()
//                }
            }
            .navigationTitle("Arkiv")
            .background(Color.myBackgroundColor)
        }
        .onAppear {
            Task {
                await viewModel.loadMealsFromArchive()
                await viewModel.loadCategoriesFromArchives()
            }
        }
        .refreshable {
            Task {
                await viewModel.loadMealsFromArchive()
                await viewModel.loadCategoriesFromArchives()
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
                    .padding(.leading, 30)
            }
            .foregroundColor(.myAlternativeTextColor)
        }
    }
}

struct ArchiveMealToolBar: ToolbarContent {
    @StateObject var viewModel = ArchiveViewModel()
    @State var meal: Meal
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                // restore
                Task {
                    print("måltid \(meal.name) vil bli gjenopprettet")
                    await viewModel.restoreMeal(meal: meal)
                    await viewModel.loadMealsFromArchive()
                    dismiss()
                }
            } label: {
                Image(systemName: "arrow.up.bin.fill")
            }
            
            Button {
                // delete permanently
                Task {
                    print("måltid \(meal.name) vil bli slettet permanent")
                    await viewModel.deleteMeal(meal: meal)
                    await viewModel.loadMealsFromArchive()
                    dismiss()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
}

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
