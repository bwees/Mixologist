//
//  MainScreen.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI

struct Screens: View {
    
    @ObservedObject private var btManager = BluetoothManager()
    @State var connectionSheetShown: Bool = true
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
        
            .sheet(isPresented: $connectionSheetShown) {
                ConnectBTView(btManager: btManager)
            }
            .onChange(of: btManager.connectionState, {
                print(btManager.connectionState)
                connectionSheetShown = btManager.connectionState != .connected
            })    
            .onAppear {
                if let savedNames = UserDefaults.standard.array(forKey: "ingredient_names") {
                    print("Loaded ingredient names!")
                } else {
                    UserDefaults.standard.set([
                        "Ingredient 1",
                        "Ingredient 2",
                        "Ingredient 3",
                        "Ingredient 4",
                        "Ingredient 5",
                        "Ingredient 6",
                        "Ingredient 7",
                        "Ingredient 8",
                    ], forKey: "ingredient_names")
                }
            }
            .environmentObject(btManager)
    }
}

