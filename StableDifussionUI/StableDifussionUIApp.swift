//
//  StableDifussionUIApp.swift
//  StableDifussionUI
//
//  Created by Carlos Martinez Medina on 4/12/22.
//

import SwiftUI

@main
struct StableDifussionUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Text2Image()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
