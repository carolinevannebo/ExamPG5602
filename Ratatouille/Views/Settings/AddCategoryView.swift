//
//  AddCategoryView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 02/12/2023.
//

import Foundation
import SwiftUI
import PhotosUI

class AddCategoryViewModel: ObservableObject {
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
    
    func addCategory(completion: @escaping (Result<CategoryModel, Error>) -> Void) async {
        var base64Image = ""
        
        if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
            base64Image = data.base64EncodedString()
        }
        
        do {
            // If any input is empty, throw error
            try throwInputErrors(base64Image)
            
            // This category will be passed as model and saved as NSObject later
            if let newCategory = CategoryModel(
                id: UUID().uuidString,
                name: name,
                image: base64Image,
                information: information
            ) {
                completion(.success(newCategory))
            } else {
                throw AddCategoryViewModelError.createNewCategoryError
            }
            
        } catch let error {
            errorMessage = NSLocalizedString("Noe gikk galt mens kategori ble laget, prøv igjen.", comment: "")
            isShowingErrorAlert = true
            completion(.failure(error))
        }
    }
    
    func throwInputErrors(_ base64Image: String) throws {
        if isEmptyInput(name, NSLocalizedString("Vennligst fyll in kategorinavn.", comment: "")) == true {
            throw AddCategoryViewModelError.inputNameEmptyError
        }
        
        if isEmptyInput(information, NSLocalizedString("Vennligst skriv informasjon om kategorien.", comment: "")) == true {
            throw AddCategoryViewModelError.inputInformationEmptyError
        }
        
        if isEmptyInput(base64Image, NSLocalizedString("Vennligst last opp kategoribilde.", comment: "")) == true {
            throw AddCategoryViewModelError.inputImageEmptyError
        }
    }
    
    func isEmptyInput(_ input: String, _ message: String) -> Bool {
        if input.isEmpty {
            errorMessage = message
            isShowingErrorAlert = true
            return true
        }
        return false
    }
    
    enum AddCategoryViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case createNewCategoryError
        case inputNameEmptyError
        case inputImageEmptyError
        case inputInformationEmptyError
    }
}

struct AddCategoryView: View {
    @StateObject var viewModel = AddCategoryViewModel()
    var completion: ((Result<CategoryModel, Error>) -> Void)
    
    init(completion: @escaping (Result<CategoryModel, Error>) -> Void) {
        self.completion = completion
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Form {
                    //TODO: legg til modifiers på textfield
                    TextField("Kategorinavn", text: $viewModel.name)
                    TextField("Informasjon", text: $viewModel.information)
                    
                    if let avatarImage = viewModel.avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFit()
                            // frame
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
                    PhotosPicker("Last opp bilde", selection: $viewModel.avatarItem, matching: .images) // buttonstyle
                    
                    Button("Legg til kategori") {
                        Task {
                            await viewModel.addCategory(completion: completion)
                        }
                    }
                }
                
            }
            .navigationTitle("Legg til kategori")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)
            // alert error messages
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}
