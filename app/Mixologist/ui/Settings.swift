//
//  ContentView.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI
import SwiftData

enum FillUnits: Int {
    case ounces = 0
    case mililiters = 1
}

struct Settings: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var drinks: [Drink]
    @Query private var ingredients: [Ingredient]
    
    @State var slotConfig = [Ingredient?](repeating: nil, count: 8)
    @State var isCleaning = false
    @State var connectionSheetShown = false
    @State var units: FillUnits = .ounces
        
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var btManager: BluetoothManager

    var body: some View {
        NavigationView {
            List {
                Button("Clean Mixologist") {
                    if (btManager.connectionState == .connected) {
                        isCleaning = true
                    } else {
                        connectionSheetShown = true
                    }
                }
                
                Picker("Measurement Units", selection: $units) {
                    Text("oz").tag(0)
                    Text("mL").tag(1)
                }
                    .pickerStyle(.segmented)
                    .onChange(of: units, {
                        UserDefaults.standard.setValue(units.rawValue, forKey: "fillUnits")
                    })
                
                Section(header: Text("Slot Setup")) {
                    ForEach(0..<8) { i in
                        Picker("Slot " + String(i+1), selection: $slotConfig[i]) {
                            Text("No Ingredient").tag(nil as Ingredient?)
                            ForEach(ingredients, id: \.id) { ingr in
                                if !slotConfig.contains(ingr) || slotConfig[i] == ingr {
                                    Text(ingr.name).tag(ingr as Ingredient?)

                                }
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .onChange(of: slotConfig) {
                        var slotIds = [String](repeating: "", count: 8)
                        
                        for (i, c) in slotConfig.enumerated() {
                            if let ingredient = c {
                                slotIds[i] = ingredient.id
                            }
                        }
                        
                        UserDefaults.standard.setValue(slotIds, forKey: "slotConfig")
                    }
                }
                
                Section(header: Text("Drinks")) {
                    Button("Add Drink") {
                        addDrink()
                    }
                    ForEach(drinks) { drink in
                        NavigationLink {
                            DrinkEdit(drink: drink)
                        } label: {
                            if !drink.recipe.keys.allSatisfy({ slotConfig.contains($0) }) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(drink.isAvailable ? .yellow : .gray)
                            }
                            Text(drink.name)
                        }
                    }
                    .onDelete(perform: deleteDrink)
                }
                Section(header: Text("Ingredients")) {
                    Button("Add Ingredient") {
                        addIngredient()
                    }
                    ForEach(ingredients) { ingredient in
                        IngredientNameEdit(ingredient: ingredient)
                    }
                    .onDelete(perform: deleteIngredient)
                }

            }
            .navigationTitle("Settings")
            .onAppear {
                let slotConfiguration: [String] = UserDefaults.standard.array(forKey: "slotConfig")! as! [String]
                
                for (i, slot) in slotConfiguration.enumerated() {
                    if slot != "" {
                        if let slotI = ingredients.first(where: {$0.id == slot}) {
                            slotConfig[i] = slotI
                        }
                    }
                }
                
                let unitsConfig: Int = UserDefaults.standard.integer(forKey: "fillUnits")
                units = FillUnits(rawValue: unitsConfig) ?? .ounces
                
            }
            .sheet(isPresented: $isCleaning) {
                CleaningScreen()
            }
            .sheet(isPresented: $connectionSheetShown) {
                ConnectBTView(btManager: btManager)
            }
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addDrink() {
        withAnimation {
            let newItem = Drink(name: "New Drink")
            modelContext.insert(newItem)
        }
    }
    
    private func addIngredient() {
        withAnimation {
            let newItem = Ingredient(name: "New Ingredient")
            modelContext.insert(newItem)
        }
    }

    private func deleteIngredient(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                var slotConfiguration: [String] = UserDefaults.standard.array(forKey: "slotConfig")! as! [String]
                
                slotConfiguration.removeAll(where: {$0 == ingredients[index].id})
                for (i, slot) in slotConfig.enumerated() {
                    if slot == ingredients[index] {
                        slotConfig[i] = nil as Ingredient?
                    }
                }
                
                for drink in drinks {
                    drink.recipe.removeValue(forKey: ingredients[index])
                }
                
                modelContext.delete(ingredients[index])
                
            }
        }
    }
    
    private func deleteDrink(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(drinks[index])
            }
        }
    }
    
}

