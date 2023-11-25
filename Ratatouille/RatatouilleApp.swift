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
    let command = InitCDCommand()
    
    var body: some Scene {
        WindowGroup {
            ViewCoordinator()
                .environment(\.managedObjectContext, DataController.shared.managedObjectContext)
                .onAppear {
                Task {
                    await command.execute(input: DataController.shared.managedObjectContext)
                }
            }
                .onDisappear {
                    DataController.shared.saveContext()
                }

        }
    }
}
