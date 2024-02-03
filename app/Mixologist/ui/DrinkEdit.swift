//
//  DrinkEdit.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI
import PhotosUI
import SwiftData

struct DrinkEdit: View {
    var drink: Drink
    
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.isPresented) var isPresented
    @EnvironmentObject var btManager: BluetoothManager
    @State var drinkImageItem: PhotosPickerItem?
    
    @State var drinkImageData: Data?
    @State var drinkName: String = ""
    @State var ingredientAmounts: [Ingredient: Int32] = [:]
    @Query var ingredients: [Ingredient]
    @State var canAddIngredients = true
    @State var isMapped = true
    @State var isAvailable = true
        
    var body: some View {
        List {
                
            Toggle("Available", isOn: $isAvailable)
            
            Section(header: Text("Name")) {
                TextField("Name", text: $drinkName)
            }
            
            Section(header: Text("Ingredients"), footer: !isMapped ? Text("Some ingredients are not mapped to pumps. Go to the main settings screen and assign the necessary ingredients.") : nil ) {
                Menu("Add Ingredient") {
                    ForEach(ingredients) { ingredient in
                        if !ingredientAmounts.contains(where: {$0.key == ingredient}) {
                            Button(ingredient.name) {
                                ingredientAmounts.updateValue(0, forKey: ingredient)
                            }
                        }
                    }
                }
                .disabled(!canAddIngredients)
                
                ForEach((Array(ingredientAmounts.keys) as! [Ingredient]).sorted {
                    $0.name < $1.name
                }) { ingredient in
                    LabeledContent {
                        TextField("Amount", value: $ingredientAmounts[ingredient], format: .number)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Text(ingredient.name == ""
                             ? "Ingredient"
                             : ingredient.name)
                    }
                }
            }
            
            Section(header: Text("Drink Image")) {
                if drinkImageData != nil {
                    HStack {
                        Spacer()
                        Image(data: drinkImageData!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .clipShape(.rect(cornerRadius: 16))
                        Spacer()
                    }
                }
                
                PhotosPicker(selection: $drinkImageItem, matching: .images) {
                    Text("Select Drink Image")
                }
                    .padding(.horizontal, 16)
                    .onChange(of: drinkImageItem) {
                        Task {
                            if let loaded = try? await drinkImageItem?.loadTransferable(type: Data.self) {
                                drinkImageData = loaded
                            } else {
                                print("Failed")
                            }
                        }
                    }
            }
        }
            .interactiveDismissDisabled()
            .onAppear {
                if drink.image != nil {
                    drinkImageData = drink.image
                }
                
                drinkName = drink.name
                
                for (ingredient, amount) in drink.recipe {
                    ingredientAmounts[ingredient] = amount
                }
                
                canAddIngredients = ingredientAmounts.count != ingredients.count
                
                let slotConfiguration: [String] = UserDefaults.standard.array(forKey: "slotConfig")! as! [String]
                isMapped = drink.recipe.keys.allSatisfy({ slotConfiguration.contains($0.id) })
                
                isAvailable = drink.isAvailable

            }
            .onChange(of: ingredientAmounts) {
                canAddIngredients = ingredientAmounts.count != ingredients.count
            }
            .onChange(of: isPresented) {
                if !isPresented {
                    drink.name = drinkName
                    drink.image = drinkImageData
                    drink.isAvailable = isAvailable
                    
                    for (ingredient, amount) in ingredientAmounts {
                        drink.recipe.updateValue(amount, forKey: ingredient)
                    }
                    
                    try! modelContext.save()
                }
            }
            .navigationTitle("Edit")
    }
}
