//
//  RatatouilleApp.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 13/11/2023.
//

import SwiftUI
import CoreData

@main
struct RatatouilleApp: App {
    let command = InitCDCommand()
    
    var body: some Scene {
        WindowGroup {
            ViewCoordinator()
                .onAppear {
                Task {
                    await command.execute(input: DataController.shared.managedObjectContext)
                }
            }
        }
    }
}
