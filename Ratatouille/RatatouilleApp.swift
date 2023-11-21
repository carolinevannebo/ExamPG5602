//
//  RatatouilleApp.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//

import SwiftUI

@main
struct RatatouilleApp: App {
    let persistenceController = PersistenceController.shared
    
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MealListView().tabItem {
                    Label("Oppskrifter", systemImage: "magnifyingglass.circle.fill")
                }
            } // TabView
        } // WindowGroup
    }
}

//var body: some Scene {
//    WindowGroup {
//        ContentView()
//            .environment(\.managedObjectContext, persistenceController.container.viewContext)
//    }
//}
