//
//  GATTDefinitions.swift
//  hoverwheel
//
//  Created by Brandon Wees on 1/18/24.
//

import Foundation
import CoreBluetooth

let DRINK_SERVICE = CBUUID(string: "523ed38f-e856-45e7-9a6e-ec9e51c3aba1")
let INGR_1_CTRL = CBUUID(string: "19b10001-e8f2-537e-4f6c-d104768a1214")
let INGR_2_CTRL = CBUUID(string: "29b10001-e8f2-537e-4f6c-d104768a1214")
let INGR_3_CTRL = CBUUID(string: "39b10001-e8f2-537e-4f6c-d104768a1214")
let INGR_4_CTRL = CBUUID(string: "49b10001-e8f2-537e-4f6c-d104768a1214")
let INGR_5_CTRL = CBUUID(string: "59b10001-e8f2-537e-4f6c-d104768a1214")
let INGR_6_CTRL = CBUUID(string: "69b10001-e8f2-537e-4f6c-d104768a1214")
let INGR_7_CTRL = CBUUID(string: "79b10001-e8f2-537e-4f6c-d104768a1214")
let INGR_8_CTRL = CBUUID(string: "89b10001-e8f2-537e-4f6c-d104768a1214")

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
