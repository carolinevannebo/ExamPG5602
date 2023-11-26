//
//  SettingsView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    
}

struct SettingsView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    var body: some View {
        NavigationStack {
                
            List {
                NavigationLink {
                    Text("Rediger landområder")
                } label : {
                    Text("Rediger landområder")
                }
                
                NavigationLink {
                    Text("Rediger kategorier")
                } label : {
                    Text("Rediger kategorier")
                }
                    
                NavigationLink {
                    Text("Rediger ingredienser")
                } label : {
                    Text("Rediger ingredienser")
                }
                
                Toggle("Aktiver mørk modus", isOn: $isDarkMode)
                    .toggleStyle(SwitchToggleStyle(tint: Color.myAccentColor))

                NavigationLink {
                    ArchiveView()
                } label : {
                    Text("Administrer arkiv")
                }
            }
            .padding()
            .scrollContentBackground(.hidden)
            .navigationTitle("Innstillinger")
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .background(Color.myBackgroundColor)
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

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
                                Text(viewModel.meals[index].name!)
                            } label: {
                                Text(viewModel.meals[index].name!)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
