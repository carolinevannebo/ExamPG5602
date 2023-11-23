//
//  Favorites.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import SwiftUI

struct Favorites: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Mine favoritter").foregroundColor(.myContrastColor)
            }
            .navigationTitle("Favoritter")
            .background(Color.myBackgroundColor)
        }
        .background(Color.myBackgroundColor)
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        Favorites()
    }
}
