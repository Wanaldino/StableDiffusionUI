//
//  StableDiffusionUIApp.swift
//  StableDiffusionUI
//
//  Created by Carlos Martinez Medina on 14/12/22.
//

import SwiftUI

@main
struct StableDiffusionUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
