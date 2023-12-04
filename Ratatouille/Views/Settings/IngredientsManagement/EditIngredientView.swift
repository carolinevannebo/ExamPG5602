//
//  EditIngredientView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 04/12/2023.
//

import Foundation
import SwiftUI
import PhotosUI

class EditIngredientViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var image: String = ""
    @Published var information: String = ""
        
    // Variables for uploading image
    @Published var avatarItem: PhotosPickerItem?
    @Published var avatarImage: Image?
    
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var ingredient: Ingredient?
    @Published var isNotAuthorized: Bool = true
    
    enum EditIngredientViewModelError: Error {
        case updateIngredientError
    }
}

struct EditIngredientView: View {
    @StateObject var viewModel = EditIngredientViewModel()
    var ingredient: Ingredient
    
    var completion: ((Result<Ingredient, Error>) -> Void)
        
    init(ingredient: Ingredient, completion: @escaping (Result<Ingredient, Error>) -> Void) {
        self.completion = completion
        self.ingredient = ingredient
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Form {
                    //TODO: legg til modifiers på textfield
                    TextField(ingredient.name ?? "Navn", text: $viewModel.name)
                    .disabled(viewModel.isNotAuthorized)
                    
                    TextField(ingredient.information ?? "Informasjon", text: $viewModel.information)
                    
                    if let avatarImage = viewModel.avatarImage {
                        avatarImage
                        .resizable()
                        .scaledToFit()
                            // frame?
                    } else if let data = Data(base64Encoded: ingredient.image ?? ""),
                        let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
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
                        viewModel.errorMessage = "Kunne ikke laste opp ingrediensbilde."
                        viewModel.isShowingErrorAlert = true
                    }
                }
                
                VStack {
                    PhotosPicker("Last opp bilde", selection: $viewModel.avatarItem, matching: .images)
                    Button("Bekreft endringer") {
                        Task { //MARK: task kjører ikke nødvendigvis på main thread, du burde sjekke alle og vurdere queue.main
                            await viewModel.editIngredient(completion: completion)
                        }
                    }
                }
                .buttonStyle(MyButtonStyle())
            }
            .navigationTitle("Rediger ingrediens")
            .padding(.horizontal)
            .alert("Feilmelding", isPresented: $viewModel.isShowingErrorAlert) {
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
            .onAppear {
                DispatchQueue.main.async {
                    viewModel.ingredient = ingredient
                    if let ingredientId = Int(ingredient.id!), (1...608).contains(ingredientId) {
                        viewModel.isNotAuthorized = true
                    } else {
                        viewModel.isNotAuthorized = false
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

extension EditIngredientViewModel {
    func editIngredient(completion: @escaping (Result<Ingredient, Error>) -> Void) async {
        var base64Image: String? = ""
            
        if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
            base64Image = data.base64EncodedString()
        }
            
        do {
            if let ingredient = ingredient {
                DispatchQueue.main.async { [self] in
                    if name.isEmpty {
                        name = ingredient.name!
                    }
                    
                    if information.isEmpty {
                        information = ingredient.information ?? ""
                    }
                }
                    
                if base64Image!.isEmpty {
                    base64Image = ingredient.image
                }
                
                
                ingredient.image = base64Image
                ingredient.information = information
                    
                // I don't want the user to change name from api
                if let ingredientId = Int(ingredient.id!), !(1...608).contains(ingredientId) {
                    ingredient.name = name
                }
               
                completion(.success(ingredient))
            } else {
                throw EditIngredientViewModelError.updateIngredientError
            }
                
        } catch let error {
            isShowingErrorAlert = true
            completion(.failure(error))
        }
    }
}
