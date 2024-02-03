//
//  Item.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import Foundation
import SwiftData

let drinkChars = [
    INGR_1_CTRL,
    INGR_2_CTRL,
    INGR_3_CTRL,
    INGR_4_CTRL,
    INGR_5_CTRL,
    INGR_6_CTRL,
    INGR_7_CTRL,
    INGR_8_CTRL
]

@Model
final class Drink {
    var name: String
    var image: Data?
    var dispenseAmounts = [Float32](repeating: 0, count: 8)
    
    init(name: String) {
        self.name = name
    }
    
    func pour(with btManager: BluetoothManager) {
        print("Pouring drink: " + name)
        print("Params: ")
        print(dispenseAmounts)
        
        for (i, dispenseAmount) in dispenseAmounts.enumerated() {
            let controlChar = btManager.drinkControl[drinkChars[i]] as! FloatAttribute
            controlChar.value = dispenseAmount
        }
    }
}
