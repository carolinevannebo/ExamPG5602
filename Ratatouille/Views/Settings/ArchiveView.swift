//
//  ArchiveView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 27/11/2023.
//

import SwiftUI

class ArchiveViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var hasArchive: Bool = false
    
    let loadCommand = LoadArchivesCommand()
    let restoreCommand = RestoreMealCommand()
    let deleteCommand = DeleteMealCommand()
    
    @Published var isNavigationActive: Bool = false
    
    func loadArchive() async {
        do {
            if let meals = await loadCommand.execute(input: ()) {
                DispatchQueue.main.async {
                    self.meals = meals
                    
                    if !meals.isEmpty {
                        self.hasArchive = true
                    } else {
                        self.hasArchive = false
                    }
                }
            } else {
                throw ArchiveViewModelError.noArchives
            }
            
        } catch {
            print("Unexpected error when loading archives to View: \(error)")
        }
    }
    
    func restoreMeal(meal: Meal) async {
        do {
            let result = await restoreCommand.execute(input: meal)
            
            switch result {
            case .success(let meal):
                print("\(meal.name) has been restored")
                // <-- go back
                DispatchQueue.main.async {
                    self.isNavigationActive = false
                }
                
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error when restoring meal from archives: \(error)")
        }
    }
    
    enum ArchiveViewModelError: Error {
        case noArchives
    }
}

struct ArchiveView: View {
    @StateObject var viewModel = ArchiveViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.hasArchive {
                    List {
                        ForEach(0..<viewModel.meals.count, id: \.self) { index in
                            ZStack {
                                ArchiveItemView(meal: viewModel.meals[index])
//                                .navigationDestination(isPresented: $viewModel.isNavigationActive) {
//                                    MealDetailView(meal: viewModel.meals[index])
//                                    .toolbar {
//                                        ArchiveToolBar(viewModel: viewModel, meal: viewModel.meals[index])
////                                            .toolbarRole(.browser)
//                                    }
//                                    
//                                    
//                                }
                                NavigationLink(
                                    destination: {
                                        MealDetailView(meal: viewModel.meals[index])
                                            .toolbar {
                                                ArchiveToolBar(viewModel: viewModel, meal: viewModel.meals[index])
                                            }
                                    }
                                ) { EmptyView() }
                                .opacity(0)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.clear)
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    .listStyle(.plain)
                } else {
                    EmptyArchiveView()
                }
            }
            .navigationTitle("Arkiv")
            .background(Color.myBackgroundColor)
        }
        .onAppear {
            Task { await viewModel.loadArchive() }
        }
        .refreshable {
            Task { await viewModel.loadArchive() }
        }
    }
}

struct ArchiveItemView: View {
    @State var meal: Meal
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.myAlternativeBgColor)
            HStack {
                Text(meal.name)
            }
            .foregroundColor(.myAlternativeTextColor)
        }
    }
}

struct ArchiveToolBar: ToolbarContent {
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
                        // <-- go back
                    dismiss()
                }
            } label: {
                Image(systemName: "arrow.up.bin")
            }
            
            Button {
                // delete permanently
                print("måltid \(meal.name) vil bli slettet permanent")
            } label: {
                Image(systemName: "trash")
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
