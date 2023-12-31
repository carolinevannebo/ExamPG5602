//
//  SettingsView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 22/11/2023.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    var body: some View {
        NavigationStack {
                
            List {
                Section {
                    NavigationLink {
                        ManageAreasView()
                    } label : {
                        Text("Rediger landområder")
                    }
                    
                    NavigationLink {
                        ManageCategoriesView()
                    } label : {
                        Text("Rediger kategorier")
                    }
                    
                    NavigationLink {
                        ManageIngredientsView()
                    } label : {
                        Text("Rediger ingredienser")
                    }
                }
                
                Toggle("Aktiver mørk modus", isOn: $isDarkMode)
                    .toggleStyle(SwitchToggleStyle(tint: Color.myAccentColor))

                Section {
                    NavigationLink {
                        ArchiveView()
                    } label : {
                        Text("Administrer arkiv")
                    }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
