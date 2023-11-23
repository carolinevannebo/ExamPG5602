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
                    Text("Administrer arkiv")
                } label : {
                    Text("Administrer arkiv")
                }
            }
            .padding()
            .scrollContentBackground(.hidden)
            .navigationTitle("Innstillinger")
            .background(Color.myBackgroundColor)
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
