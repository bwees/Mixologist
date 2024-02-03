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
    @State var drinkProgress = [Int32](repeating: 0, count: 8)
    @State var ingredientNames = [String](repeating: "", count: 8)
    @State var totalProgress: Float = 0
    
    @State var drink: Drink?
    
    var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            if drink != nil {
                
                Text("Preparing a " + drink!.name)
                    .font(.largeTitle.bold())
                    .padding(.top, 48)
                    .padding(.horizontal, 24)
                
                List {
                    ForEach(0..<8) { i in
                        if drink?.dispenseAmounts[i] != 0 {
                            LabeledContent {
                                if drinkProgress[i] == 0 {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.green)
                                } else {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                            } label: {
                                Text(ingredientNames[i] == "" 
                                     ? "Tube " + String(i+1)
                                     : ingredientNames[i]
                                )
                            }
                        }
                    }
                }
                
                .onAppear {
                    drink?.pour(with: btManager)
                }
                .onReceive(timer) { input in
                    drinkProgress = btManager.getProgress()
                    
                    if drinkProgress.allSatisfy({ $0 == 0 }) {
                        timer.upstream.connect().cancel()
                        print("Complete!")
                        dismiss()
                    }
                }
            }
        }
            .onAppear {
                drink = allDrinks.filter({$0.id == drinkID}).first
                
                if let savedNames = UserDefaults.standard.array(forKey: "ingredient_names") {
                    ingredientNames = savedNames as! [String]
                }
            }
        
    }
        
}
