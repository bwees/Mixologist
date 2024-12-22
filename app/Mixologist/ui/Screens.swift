//
//  MainScreen.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI

struct Screens: View {
    
    @ObservedObject private var btManager = BluetoothManager()
    @State var settingsShown = false

    var body: some View {
        NavigationView {
            DrinkSelector()
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
        }
            .sheet(isPresented: $settingsShown, content: {
                Settings()
            })
            .environmentObject(btManager)
            .onAppear {
                if UserDefaults.standard.array(forKey: "slotConfig") != nil {
                    print("loaded slot configuration")
                } else {
                    UserDefaults.standard.setValue([String](repeating: "", count: 8), forKey: "slotConfig")
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

