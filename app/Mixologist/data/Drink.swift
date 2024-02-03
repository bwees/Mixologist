//
//  Item.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import Foundation
import SwiftData

@Model
final class Drink {
    var name: String
    var image: Data?
    var dispenseAmounts = [Int32](repeating: 0, count: 8)
    var id: String
    
    init(name: String) {
        self.name = name
        self.id = UUID().uuidString
    }
    
    func pour(with btManager: BluetoothManager) {
        for (i, dispenseAmount) in dispenseAmounts.enumerated() {
            let controlChar = btManager.drinkControl[drinkChars[i]] as! IntAttribute
            controlChar.value = dispenseAmount
        }
        
        btManager.writeControls()
    }
}
