//
//  Item.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import Foundation
import SwiftData

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
                slotControl.value = dispenseAmount
            }
        }
        
        btManager.writeControls()
    }
}
