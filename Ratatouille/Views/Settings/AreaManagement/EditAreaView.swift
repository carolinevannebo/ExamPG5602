//
//  EditAreaView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 04/12/2023.
//

import Foundation
import SwiftUI

class EditAreaViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var area: Area?
    @Published var isNotAuthorized: Bool = true
    
    // Error messages
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
            
    enum EditAreaViewModelError: Error, LocalizedError {
        case updateAreaError
    }
}

struct EditAreaView: View {
    @StateObject var viewModel = EditAreaViewModel()
    var area: Area
        
    var completion: ((Result<Area, Error>) -> Void)
            
    init(area: Area, completion: @escaping (Result<Area, Error>) -> Void) {
        self.completion = completion
        self.area = area
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Form {
                    // TODO: lag en enum og bruk selector som kun tillater landområder som har flagg api
                    TextField(area.name, text: $viewModel.name)
                        .disabled(viewModel.isNotAuthorized)
                    
                    Button("Bekreft endringer") {
                        Task {
                            if viewModel.isNotAuthorized {
                                viewModel.errorMessage = "Du kan bare redigere dine egne landområder"
                                viewModel.isShowingErrorAlert = true
                            } else {
                                await viewModel.editArea(completion: completion)
                            }
                        }
                    }
                    .buttonStyle(MyButtonStyle())
                }
            }
            .navigationTitle("Rediger til landområde")
            .padding(.horizontal)
            .alert("Feilmelding", isPresented: $viewModel.isShowingErrorAlert) {
            } message: {
                Text($viewModel.errorMessage.wrappedValue)
            }
            .onAppear {
                DispatchQueue.main.async {
                    viewModel.area = area
                    if let areaId = Int(area.id!), (1...608).contains(areaId) {
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

extension EditAreaViewModel {
    func editArea(completion: @escaping (Result<Area, Error>) -> Void) async {
        do {
            if let area = area {
                DispatchQueue.main.async { [self] in
                    if name.isEmpty {
                        name = area.name
                    }
                }
                    area.name = name
                print("sending area with name \(area.name)")
                
                
                completion(.success(area))
            } else {
                throw EditAreaViewModelError.updateAreaError
            }
                
        } catch let error {
            isShowingErrorAlert = true
            completion(.failure(error))
        }
    }
}
