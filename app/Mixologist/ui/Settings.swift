//
//  ContentView.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI
import SwiftData

struct Settings: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var drinks: [Drink]
    @Query private var ingredients: [Ingredient]
    
    @State var slotConfig = [Ingredient?](repeating: nil, count: 8)
    @State var isCleaning = false
        
    @Environment(\.dismiss) var dismiss
    

    var body: some View {
        NavigationView {
            List {
                Button("Clean Mixologist") {
                    isCleaning = true
                }
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
            }
            .sheet(isPresented: $isCleaning) {
                CleaningScreen()
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
                modelContext.delete(ingredients[index])
                
                for drink in drinks {
                    drink.recipe.removeValue(forKey: ingredients[index])
                }
                
                var slotConfiguration: [String] = UserDefaults.standard.array(forKey: "slotConfig")! as! [String]
                
                slotConfiguration.removeAll(where: {$0 == ingredients[index].id})
                slotConfig.removeAll(where: {$0?.id == ingredients[index].id})
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

