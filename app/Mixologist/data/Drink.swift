//
//  Item.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import Foundation
import SwiftData

let ML_TO_S = 620
let DRINK_SCALE = 1

@Model
final class Drink: Identifiable {
    var name: String
    var image: Data?
    var recipe: [Ingredient: Int32] = [:]
    var id: String
    var isAvailable: Bool
    
    init(name: String) {
        self.name = name
        self.id = UUID().uuidString
        self.isAvailable = true
    }
    
    func pour(with btManager: BluetoothManager) {
        
        for (ingredient, dispenseAmount) in recipe {
            if let slotIndex = ingredient.getSlotIndex() {
                if slotIndex == -1 {
                    btManager.cancelPour()
                }
                
                let slotControl = btManager.slotControls[slotCharArray[slotIndex]] as! IntAttribute
                slotControl.value = dispenseAmount * Int32(ML_TO_S) * Int32(DRINK_SCALE)
            }
        }
        
        btManager.writeControls()
    }
}
