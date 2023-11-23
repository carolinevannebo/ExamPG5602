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
            ViewCoordinator()
                .environment(\.managedObjectContext, DataController.shared.managedObjectContext)
                .onAppear {
                Task {
                    await initCD.execute(input: DataController.shared.managedObjectContext)
                }
            }
        }
    }
}
