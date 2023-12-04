//
//  EditMealView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 04/12/2023.
//

// TODO: få inn flere felter

import Foundation
import SwiftUI
import PhotosUI

class EditMealViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var image: String = ""
    @Published var instructions: String = ""
    
    // Variables for uploading image
    @Published var avatarItem: PhotosPickerItem?
    @Published var avatarImage: Image?
    
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var meal: Meal?
    
    enum EditMealViewModelError: Error {
        case updateMealError
    }
}

struct EditMealView: View {
    @StateObject var viewModel = EditMealViewModel()
    var meal: Meal
    var completion: ((Result<Meal, Error>) -> Void)
    
    init(meal: Meal, completion: @escaping (Result<Meal, Error>) -> Void) {
        self.completion = completion
        self.meal = meal
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Form {
                    //TODO: legg til modifiers på textfield
                    TextField(meal.name, text: $viewModel.name)
                    TextField(meal.instructions ?? "Instruksjoner", text: $viewModel.instructions)
                        .frame(height: 200)
                    
                    if let avatarImage = viewModel.avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFit()
                            // frame?
                    } else if let data = Data(base64Encoded: meal.image!),
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
                        viewModel.errorMessage = "Kunne ikke laste opp bildets måltid."
                        viewModel.isShowingErrorAlert = true
                    }
                }
                
                VStack {
                    PhotosPicker("Last opp bilde", selection: $viewModel.avatarItem, matching: .images)
                    
                    Button("Bekreft endringer") {
                        Task {
                            await viewModel.editMeal(completion: completion)
                        }
                    }
                }
                .buttonStyle(MyButtonStyle())
            }
            .padding(.horizontal)
            .navigationTitle("Rediger måltid")
            .alert("Feilmelding", isPresented: $viewModel.isShowingErrorAlert) {
                
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
            .onAppear {
                DispatchQueue.main.async {
                    viewModel.meal = meal
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

extension EditMealViewModel {
    func editMeal(completion: @escaping (Result<Meal, Error>) -> Void) async {
        var base64Image: String? = ""
        
        if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
            base64Image = data.base64EncodedString()
        }
        
        do { // TODO: REFACTOR
            if let meal = meal {
                DispatchQueue.main.async { [self] in
                    if name.isEmpty {
                        name = meal.name
                    }
                    
                    if instructions.isEmpty {
                        instructions = meal.instructions!
                    }
                }
                if base64Image!.isEmpty {
                    base64Image = meal.image
                }
                
                if !name.isEmpty {
                    meal.name = name
                }
                
                if !instructions.isEmpty {
                    meal.instructions = instructions
                }
                
                meal.image = base64Image
                
                completion(.success(meal))
            } else {
                throw EditMealViewModelError.updateMealError
            }
            
        } catch let error {
            isShowingErrorAlert = true
            completion(.failure(error))
        }
    }
}
