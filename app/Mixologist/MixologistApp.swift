//
//  MixologistApp.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI
import SwiftData

@main
struct MixologistApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Drink.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
