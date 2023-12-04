//
//  AddMealView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 04/12/2023.
//

import Foundation
import SwiftUI
import PhotosUI

class AddMealViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var image: String = ""
    @Published var instructions: String = ""
    @Published var category: String = ""
    
    @Published var area: AreaModel?
    @Published var selectedAreaId: String = UUID().uuidString
    @Published var areas: [AreaModel]?
//    @Published var category: CategoryModel?
//    @Published var ingredient: IngredientModel?
//    @Published var ingredients: [String] = []
    
    
    // Variables for uploading image
    @Published var avatarItem: PhotosPickerItem?
    @Published var avatarImage: Image?
    
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var meal: MealModel?
    
    enum AddMealViewModelError: Error {
        case addMealError
        case inputNameEmptyError
        case inputImageEmptyError
        case inputInstructionsEmptyError
        case fetchingAreasError
        case settingAreaError
    }
}

struct AddMealView: View {
    @StateObject var viewModel = AddMealViewModel()
    @State var completion: ((Result<MealModel, Error>) -> Void)
    
    init(completion: @escaping (Result<MealModel, Error>) -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                AddMealForm(viewModel: viewModel, completion: $completion)
            }
            .padding(.horizontal)
            .navigationTitle("Lagre måltid")
            .alert("Feilmelding", isPresented: $viewModel.isShowingErrorAlert) {
                
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
            .onAppear {
                Task {
                    await viewModel.loadAreas()
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

struct AddMealForm: View {
    @StateObject var viewModel: AddMealViewModel
    @Binding var completion: ((Result<MealModel, Error>) -> Void)
    
    var body: some View {
        Form { // TODO: form skulle vært refaktorert og gjenbrukt
            //TODO: legg til modifiers på textfield
            TextField("Oppskriftsnavn", text: $viewModel.name)
            TextField("Kategori", text: $viewModel.category)
            
            if viewModel.areas != nil {
                Picker("Landområde", selection: $viewModel.selectedAreaId) {
                    ForEach(0..<viewModel.areas!.count, id: \.self) { index in
                        Text(viewModel.areas![index].name)
                            .tag(viewModel.areas![index].id)
                    }
                }
            }
            
            TextField("Instruksjoner", text: $viewModel.instructions)
                .frame(height: 200)
            
            if let avatarImage = viewModel.avatarImage {
                avatarImage
                    .resizable()
                    .scaledToFit()
                    // frame?
            }
            
        }
        .onChange(of: viewModel.avatarItem) { _ in
            Task {
                if let data = try? await viewModel.avatarItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        viewModel.avatarImage = Image(uiImage: uiImage)
                        return
                    }
                }
                viewModel.errorMessage = "Kunne ikke laste opp bildets måltid."
                viewModel.isShowingErrorAlert = true
            }
        }
        
        VStack {
            PhotosPicker("Last opp bilde", selection: $viewModel.avatarItem, matching: .images)
            
            Button("Bekreft endringer") {
                Task {
                    await viewModel.addNewMeal(completion: completion)
                }
            }
        }
        .buttonStyle(MyButtonStyle())
    }
}

extension AddMealViewModel {
    func addNewMeal(completion: @escaping (Result<MealModel, Error>) -> Void) async {
        var base64Image: String? = ""
        
        if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
            base64Image = data.base64EncodedString()
        }
        
        do { // TODO: REFACTOR
            // If any input is empty, throw error
            try throwInputErrors(base64Image!)
            
//            guard let selectedArea = areas?.first(where: { $0.id == selectedAreaId }) else {
//                throw AddMealViewModelError.settingAreaError
//            }
            if let selectedArea = areas?.first(where: { $0.id == selectedAreaId }) {
                area = selectedArea
            }
            
            // very simple implementation for the moment
            if let newMeal = MealModel(
                id: UUID().uuidString,
                name: name,
                image: base64Image ?? "",
                instructions: instructions,
                area: (area ?? AreaModel(name: "", id: ""))!, // doesnt work
                category: CategoryModel(
                    id: UUID().uuidString,
                    name: category,
                    image: "",
                    information: ""
                )!,
                ingredients: [],
                isFavorite: true
            ) {
                completion(.success(newMeal))
            } else {
                throw AddMealViewModelError.addMealError
            }
            
        } catch let error {
            isShowingErrorAlert = true
            completion(.failure(error))
        }
    }
    
    func loadAreas() async {
        do {
            if let areas = await LoadAreasFromAPICommand().execute(input: ()) {
                DispatchQueue.main.async {
                    self.areas = areas
                }
            } else {
                throw AddMealViewModelError.fetchingAreasError
            }
        } catch {
            print("Unexpected error \(error)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isShowingErrorAlert = true
            }
        }
    }

    func throwInputErrors(_ base64Image: String) throws {
        if isEmptyInput(name, NSLocalizedString("Vennligst fyll in navn på måltid.", comment: "")) == true {
            throw AddMealViewModelError.inputNameEmptyError
        }
        
        if isEmptyInput(instructions, NSLocalizedString("Vennligst skriv instruksjoner.", comment: "")) == true {
            throw AddMealViewModelError.inputInstructionsEmptyError
        }
        
        if isEmptyInput(base64Image, NSLocalizedString("Vennligst last opp bilde av måltidet.", comment: "")) == true {
            throw AddMealViewModelError.inputImageEmptyError
        }
    }
        
    func isEmptyInput(_ input: String, _ message: String) -> Bool {
        if input.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = message
                self.isShowingErrorAlert = true
            }
            
            return true
        }
        return false
    }
}
