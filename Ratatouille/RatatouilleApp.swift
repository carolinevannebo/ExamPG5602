//
//  RatatouilleApp.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//

import SwiftUI
import CoreData

@main
struct RatatouilleApp: App {
    let initCD = InitCD()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MealListView().tabItem {
                    Label("Oppskrifter", systemImage: "magnifyingglass.circle.fill")
                }
            } // TabView
            .environment(\.managedObjectContext, DataController.shared.managedObjectContext)
            .environment(\.colorScheme, .dark)
            .onAppear {
                Task {
                    // Debugging
                    //UserDefaults.standard.setValue(true, forKey: "com.apple.CoreData.SQLDebug")
                    await initCD.execute(input: DataController.shared.managedObjectContext)
                }
            }
        } // WindowGroup
    }
}

