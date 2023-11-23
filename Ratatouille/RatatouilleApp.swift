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
            MainView()
                .modifier(DarkModeViewModifier())
                .environment(\.managedObjectContext, DataController.shared.managedObjectContext)
                .onAppear {
                Task {
                    await initCD.execute(input: DataController.shared.managedObjectContext)
                }
            }
        }
    }
}

struct MainView: View {
    @State private var selection = 2
    
    var body: some View {
        TabView(selection: $selection) {
            Favorites().tabItem {
                Label("Favoritter", systemImage: "heart.circle.fill")
            }.tag(1)
            
            
            MealListView().tabItem {
                Label("Oppskrifter", systemImage: "magnifyingglass.circle.fill")
            }.tag(2)
            
            SettingsView().tabItem {
                Label("Innstillinger", systemImage: "gear.circle.fill")
            }.tag(3)
        }
    }
}
