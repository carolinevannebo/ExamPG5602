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
                    ScrollView {
                        ForEach(0..<viewModel.meals.count, id: \.self) { index in
                            NavigationLink {
                                Text(viewModel.meals[index].name)
                            } label: {
                                HStack {
                                    Text(viewModel.meals[index].name)
                                    Image(systemName: "trash")
                                    Image(systemName: "arrow.up.bin")
                                }
                            }
                        }
                    }
                } else {
                    Spacer().frame(maxWidth: .infinity)
                    
                    Image(systemName: "square.stack.3d.up.slash")
                        .foregroundColor(.myPrimaryColor)
                        .font(.system(size: 40))
                    
                    Text("Tomt arkiv")
                        .foregroundColor(.mySecondaryColor)
                    
                    Spacer().frame(maxWidth: .infinity)
                }
                
            }
            .navigationTitle("Arkiv")
            .background(Color.myBackgroundColor)
        }
        .onAppear {
            Task {
                await viewModel.loadArchive()
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
