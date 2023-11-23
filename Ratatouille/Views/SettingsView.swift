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
        VStack {
            Toggle("Mørkt tema", isOn: $isDarkMode).padding()
        }
        .navigationTitle("Innstillinger")
        .background(Color.myBackgroundColor)
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
