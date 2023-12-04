//
//  AddAreaView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 04/12/2023.
//

import Foundation
import SwiftUI

class AddAreaViewModel: ObservableObject {
    @Published var name: String = ""
    
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
            
    enum AddAreaViewModelError: Error, LocalizedError {
        case failed(underlying: Error)
        case createNewAreaError
        case inputNameEmptyError
    }
}

struct AddAreaView: View {
    @StateObject var viewModel = AddAreaViewModel()
    var completion: ((Result<AreaModel, Error>) -> Void)
    
    init(completion: @escaping (Result<AreaModel, Error>) -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Form {
                    // TODO: lag en enum og bruk selector som kun tillater landområder som har flagg api
                    TextField("Navn på landområde (engelsk)", text: $viewModel.name)
                    
                    Button("Legg til nytt landområde") {
                        Task {
                            await viewModel.addArea(completion: completion)
                        }
                    }
                    .buttonStyle(MyButtonStyle())
                }
            }
            .navigationTitle("Legg til landområde")
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

extension AddAreaViewModel {
    func addArea(completion: @escaping (Result<AreaModel, Error>) -> Void) async {
        do {
            if isEmptyInput(name, NSLocalizedString("Vennligst fyll inn navn på landområdet.", comment: "")) == true {
                throw AddAreaViewModelError.inputNameEmptyError
            }
            
            if let newArea = AreaModel(
                name: name,
                id: UUID().uuidString
            ) {
                completion(.success(newArea))
            } else {
                throw AddAreaViewModelError.createNewAreaError
            }
                        
        } catch let error {
            DispatchQueue.main.async {
                self.isShowingErrorAlert = true
            }
            completion(.failure(error))
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
