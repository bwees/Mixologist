//
//  DrinkSelector.swift
//  Mixologist
//
//  Created by Brandon Wees on 2/2/24.
//

import SwiftUI
import SwiftData

struct DrinkSelector: View {
    @Query private var drinks: [Drink]

    var body: some View {
        TabView {
            ForEach(drinks) { drink in
                DrinkCard(drink: drink)
            }
            .padding(.bottom, 16)
            .padding([.horizontal], 16)

        }
            .tabViewStyle(.page)
        
    }
}

#Preview {
    DrinkSelector()
}
