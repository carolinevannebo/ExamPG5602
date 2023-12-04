//
//  AddIngredientView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import SwiftUI
import PhotosUI

class AddIngredientViewModel: ObservableObject {
    // I want the user to populate data to all fields, so no optionals
    @Published var name: String = ""
    @Published var image: String = ""
    @Published var information: String = ""
        
    // Variables for uploading image
    @Published var avatarItem: PhotosPickerItem?
    @Published var avatarImage: Image?
        
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
        
    enum AddIngredientViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case createNewIngredientError
        case inputNameEmptyError
        case inputImageEmptyError
        case inputInformationEmptyError
    }
}

struct AddIngredientView: View {
    @StateObject var viewModel = AddIngredientViewModel()
    var completion: ((Result<IngredientModel, Error>) -> Void)
        
    init(completion: @escaping (Result<IngredientModel, Error>) -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Form {
                    //TODO: legg til modifiers på textfield
                    TextField("Ingrediensnavn", text: $viewModel.name)
                    TextField("Informasjon", text: $viewModel.information)
                    
                    if let avatarImage = viewModel.avatarImage {
                        avatarImage
                        .resizable()
                        .scaledToFit()
                        // frame?
                    }
                }.onChange(of: viewModel.avatarItem) { _ in
                    Task {
                        if let data = try? await viewModel.avatarItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                viewModel.avatarImage = Image(uiImage: uiImage)
                                return
                            }
                        }
                        viewModel.errorMessage = "Kunne ikke laste opp kategoribilde."
                        viewModel.isShowingErrorAlert = true
                    }
                }
                
                VStack {
                    PhotosPicker("Last opp bilde", selection: $viewModel.avatarItem, matching: .images)
                                    
                    Button("Legg til ingrediens") {
                        Task {
                            await viewModel.addIngredient(completion: completion)
                        }
                    }
                }
                .buttonStyle(MyButtonStyle())
            }
            .navigationTitle("Legg til ingrediens")
            .padding(.horizontal)
            .alert("Feilmelding", isPresented: $viewModel.isShowingErrorAlert) {
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

extension AddIngredientViewModel {
    func addIngredient(completion: @escaping (Result<IngredientModel, Error>) -> Void) async {
        var base64Image = ""
                
        if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
            base64Image = data.base64EncodedString()
        }
        
        do {
            // If any input is empty, throw error
            try throwInputErrors(base64Image)
                    
            // This ingredient will be passed as model and saved as NSObject later
            // I want to force the user to upload an image, because it is annoying that the API did not provide it
            if let newIngredient = IngredientModel(
                id: UUID().uuidString,
                name: name,
                information: information,
                image: base64Image
            ) {
                completion(.success(newIngredient))
            } else {
                throw AddIngredientViewModelError.createNewIngredientError
            }
                    
        } catch let error {
            DispatchQueue.main.async {
                self.isShowingErrorAlert = true
            }
            completion(.failure(error))
        }
    }
    
    func throwInputErrors(_ base64Image: String) throws {
        if isEmptyInput(name, NSLocalizedString("Vennligst fyll inn navn på ingrediensen.", comment: "")) == true {
            throw AddIngredientViewModelError.inputNameEmptyError
        }
            
        if isEmptyInput(information, NSLocalizedString("Vennligst skriv informasjon om ingrediensen.", comment: "")) == true {
            throw AddIngredientViewModelError.inputInformationEmptyError
        }
            
        if isEmptyInput(base64Image, NSLocalizedString("Vennligst last opp bilde av ingrediensen.", comment: "")) == true {
            throw AddIngredientViewModelError.inputImageEmptyError
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
