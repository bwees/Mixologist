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
    @Query private var items: [Drink]
    
    @Environment(\.dismiss) var dismiss
    
    @State var ingredientNames = [String](repeating: "", count: 8)

    var body: some View {
        NavigationView {
                List {
                    Section(header: Text("Drinks")) {
                        ForEach(items) { drink in
                            NavigationLink {
                                DrinkEdit(drink: drink)
                            } label: {
                                Text(drink.name)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    Section(header: Text("Ingredient Names")) {
                        ForEach(0..<8) { slot_num in
                            LabeledContent {
                                TextField("Ingredient Name", text: $ingredientNames[slot_num])
                                    .multilineTextAlignment(.trailing)
                            } label: {
                                Text("Tube " + String(slot_num+1))
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .onChange(of: ingredientNames) {
                        UserDefaults.standard.set(ingredientNames, forKey: "ingredient_names")
                    }
                }
                .navigationTitle("Settings")
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            addItem()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    if let savedNames = UserDefaults.standard.array(forKey: "ingredient_names") {
                        ingredientNames = savedNames as! [String]
                    }
                }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Drink(name: "new drink")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

