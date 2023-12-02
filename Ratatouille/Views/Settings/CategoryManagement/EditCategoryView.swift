//
//  EditCategoryView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 02/12/2023.
//

import Foundation
import SwiftUI
import _PhotosUI_SwiftUI

class EditCategoryViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var image: String = ""
    @Published var information: String = ""
    
//    @Published var placeHolderImage: UIImage?
//    @Published var isLoadingPlaceHolderImage = false
    
    // Variables for uploading image
    @Published var avatarItem: PhotosPickerItem?
    @Published var avatarImage: Image?
    
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var category: Category?
    
    func editCategory(completion: @escaping (Result<Category, Error>) -> Void) async {
        var base64Image: String? = ""
        
        if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
            base64Image = data.base64EncodedString()
        }
        
        do {
            if let category = category {
                if name.isEmpty {
                    name = category.name
                }
                
                if information.isEmpty {
                    information = category.information!
                }
                
                if ((base64Image?.isEmpty) != nil) {
                    base64Image = category.image
                }
                
                category.name = name
                category.information = information
                category.image = base64Image
                
                completion(.success(category))
            } else {
                throw EditCategoryViewModelError.updateCategoryError
            }
            
        } catch let error {
            isShowingErrorAlert = true
            completion(.failure(error))
        }
    }
    
    enum EditCategoryViewModelError: Error {
        case updateCategoryError
    }
}

struct EditCategoryView: View {
    @StateObject var viewModel = EditCategoryViewModel()
    var category: Category
    var completion: ((Result<Category, Error>) -> Void)
    
    init(category: Category, completion: @escaping (Result<Category, Error>) -> Void) {
        self.completion = completion
        self.category = category
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Form {
                    //TODO: legg til modifiers på textfield
                    TextField(category.name, text: $viewModel.name)
                    TextField(category.information ?? "Information", text: $viewModel.information)
                    
                    if let avatarImage = viewModel.avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFit()
                            // frame?
                    } else if let data = Data(base64Encoded: category.image!),
                              let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
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
                    
                    Button("Bekreft endringer") {
                        Task {
                            await viewModel.editCategory(completion: completion)
                        }
                    }
                }
                .buttonStyle(MyButtonStyle())
            }
            .padding(.horizontal)
            .navigationTitle("Rediger kategori")
            .alert("Feilmelding", isPresented: $viewModel.isShowingErrorAlert) {
                
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
            .onAppear {
                DispatchQueue.main.async {
                    viewModel.category = category
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}
