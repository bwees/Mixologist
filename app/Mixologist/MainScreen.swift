//
//  MainScreen.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI

struct MainScreen: View {
    
    @State var settingsShown = false

    var body: some View {
        Text("Fuck you")
            .navigationTitle("Mixologist")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        settingsShown = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $settingsShown, content: {
                Settings()
            })
    }
}

#Preview {
    MainScreen()
}
