//
//  Favorites.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 22/11/2023.
//

import SwiftUI

struct Favorites: View {
    var body: some View {
        VStack {
            Text("Mine favoritter").foregroundColor(.myContrastColor)
        }
        .navigationTitle("Favoritter")
        .background(Color.myBackgroundColor)
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        Favorites()
    }
}
