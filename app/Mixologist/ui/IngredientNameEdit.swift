//
//  IngredientNameEdit.swift
//  Mixologist
//
//  Created by Brandon Wees on 2/3/24.
//

import SwiftUI
import SwiftData

struct IngredientNameEdit: View {
    var ingredient: Ingredient
    @State var ingredientName = ""
    @Environment(\.modelContext) var modelContext
    
    @Query var drinks: [Drink]
    
    var body: some View {
        TextField("Ingredient Name", text: $ingredientName)
            .onAppear {
                ingredientName = ingredient.name
            }
            .onChange(of: ingredientName) {
                ingredient.name = ingredientName
                
                // update ingredient names
                for drink in drinks {
                    if let ingr = drink.recipe[ingredient] {
                        drink.recipe.removeValue(forKey: ingredient)
                        drink.recipe.updateValue(ingr, forKey: ingredient)
                    }
                }
                
                try! modelContext.save()
            }
    }
}

