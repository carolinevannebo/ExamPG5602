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
    let dataController = DataController.shared
//    let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    let initCD = InitCD()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MealListView().tabItem {
                    Label("Oppskrifter", systemImage: "magnifyingglass.circle.fill")
                }
            } // TabView
            .environment(\.managedObjectContext, dataController.persistentContainer.viewContext)
            .environment(\.colorScheme, .dark)
            .onAppear {
                Task {
                    // Add this line at the beginning of your app or in a suitable place
                    UserDefaults.standard.setValue(true, forKey: "com.apple.CoreData.SQLDebug")
                    await initCD.execute(input: dataController.persistentContainer.viewContext)
                }
            }
        } // WindowGroup
    }
}

