//
//  ContentView.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        
        NavigationView {
            MainScreen()

        }
        .modelContainer(for: Drink.self)
    }
}

#Preview {
    ContentView()
}
