//
//  DrinkEdit.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI

struct DrinkEdit: View {
    var drink: Drink
    @Environment(\.modelContext) private var modelContext

    
    var body: some View {
        VStack {
            Text(drink.x)
            Button("Edit Drink Button") {
                drink.x = "help"
                
                try? modelContext.save()
               
            }
        }
        
    }
}
