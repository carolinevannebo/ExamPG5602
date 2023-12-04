//
//  MealListView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 27/11/2023.
//

import SwiftUI

struct MealListView: View {
    @StateObject var viewModel: RecipeBrowserViewModel
    @State private var isHeartSelected = false
    
    var body: some View {
        VStack {
            ForEach(0..<viewModel.meals.count, id: \.self) { index in
                NavigationLink {
                    MealDetailView(meal: viewModel.meals[index])
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Button {
                                    withAnimation(.easeInOut) {
                                        isHeartSelected.toggle()
                                        Task {
                                            await viewModel.saveMeal(meal: $viewModel.meals[index].wrappedValue)
                                        }
                                    }
                                } label: {
                                    Image(systemName: isHeartSelected ? "heart.fill" : "heart")
                                        .font(.system(size: 20))
                                }
                            }
                        }
                } label: {
                    MealItemView(meal: viewModel.meals[index])
                }
            }.id(viewModel.searchId)
        }
        .padding(.vertical)
        .onAppear {
            Task { await viewModel.searchMeals(isDemo: true) }
        }
    }
}

struct MealListView_Previews: PreviewProvider {
    static var previews: some View {
        MealListView(viewModel: RecipeBrowserViewModel())
    }
}

// last minute add on
extension RecipeBrowserViewModel {
    func saveMeal(meal: MealModel) async {
        do {
            let result = await saveCommand.execute(input: meal)
            
            switch result {
            case .success(let favorite):
                print("Saving \(String(describing: favorite.name)) succeeded")
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
