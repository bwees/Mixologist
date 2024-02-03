//
//  PourProgress.swift
//  Mixologist
//
//  Created by Brandon Wees on 2/2/24.
//

import SwiftUI
import SwiftData

struct PourProgress: View {
    
    var drinkID: String
        
    @EnvironmentObject var btManager: BluetoothManager
    @Environment(\.dismiss) var dismiss
    
    @Query var allDrinks: [Drink]
    @Query var ingredients: [Ingredient]
    @State var drinkProgress = [Int32](repeating: 0, count: 8)
    @State var ingredientNames = [String](repeating: "", count: 8)
    @State var totalProgress: Float = 0
    
    @State var drink: Drink?
    
    var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            if let drink = drink {
                
                Text("Preparing a " + drink.name)
                    .font(.largeTitle.bold())
                    .padding(.top, 48)
                    .padding(.horizontal, 24)
                
                List {
                    ForEach((Array(drink.recipe.keys) as! [Ingredient]).sorted {
                        $0.name < $1.name
                    }) { ingredient in
                        var slotIndex = ingredient.getSlotIndex()
                        var slotConfiguration: [String?] = UserDefaults.standard.array(forKey: "slotConfig")! as! [String?]
                        var slotIngredient = ingredients.first(where: {$0.id == slotConfiguration[slotIndex!]})
                        
                        LabeledContent {
                            if drinkProgress[slotIndex!] == 0 {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.green)
                            } else {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                        } label: {
                            Text(slotIngredient!.name == ""
                                  ? "Ingredient"
                                 : slotIngredient!.name
                            )
                        }

                    }
                }
                
                .onAppear {
                    drink.pour(with: btManager)
                }
                .onReceive(timer) { input in
                    drinkProgress = btManager.getProgress()
                    
                    if drinkProgress.allSatisfy({ $0 == 0 }) {
                        timer.upstream.connect().cancel()
                        print("Complete!")
                        dismiss()
                    }
                }
                .interactiveDismissDisabled()
            }
        }
            .onAppear {
                drink = allDrinks.filter({$0.id == drinkID}).first
            }
        
    }
        
}
