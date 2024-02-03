//
//  HoverwheelBLE.swift
//  hoverwheel
//
//  Created by Brandon Wees on 1/17/24.
//

import Foundation
import CoreBluetooth
import SwiftUI
import Combine

enum BTConnectionState {
    case connected, disconnected, connecting
}

class BluetoothManager: NSObject, ObservableObject, Observable {
    private var centralManager: CBCentralManager?
    
    @Published var peripherals: [CBPeripheral] = []
    @Published var selectedDevice: CBPeripheral?
    @Published var connectionState: BTConnectionState = .disconnected
    @Published var shouldAutoconnect: Bool = true
    
    @Published var drinkControl: [CBUUID: any GATTAttribute] = [
        INGR_1_CTRL: FloatAttribute(name: "Ingredient 1 Control"),
        INGR_2_CTRL: FloatAttribute(name: "Ingredient 2 Control"),
        INGR_3_CTRL: FloatAttribute(name: "Ingredient 3 Control"),
        INGR_4_CTRL: FloatAttribute(name: "Ingredient 4 Control"),
        INGR_5_CTRL: FloatAttribute(name: "Ingredient 5 Control"),
        INGR_6_CTRL: FloatAttribute(name: "Ingredient 6 Control"),
        INGR_7_CTRL: FloatAttribute(name: "Ingredient 7 Control"),
        INGR_8_CTRL: FloatAttribute(name: "Ingredient 8 Control")
    ]

    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        scanForDevices()
    }
    
    func connectToPeripheral(peripheral: CBPeripheral) {
        self.centralManager?.connect(peripheral)
        self.selectedDevice = peripheral
        self.connectionState = .connecting
    }
    
    func disconnectPeripheral() {
        if self.selectedDevice == nil || self.connectionState != .connected {
            return
        }
        self.centralManager?.cancelPeripheralConnection(self.selectedDevice!)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectionState = .connected
        self.selectedDevice = peripheral
        
        peripheral.delegate = self
        peripheral.discoverServices([
            DRINK_SERVICE
        ])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.connectionState = .disconnected
        self.selectedDevice = nil
        self.peripherals = []
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.connectionState = .disconnected
        self.selectedDevice = nil
        self.peripherals = []
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!peripherals.contains(peripheral)) {
            self.peripherals.append(peripheral)
            if shouldAutoconnect {
                self.connectToPeripheral(peripheral: peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("Error discovering services: \(String(describing: error?.localizedDescription))")
            return
        }

        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering services: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if service.uuid == DRINK_SERVICE {
            // Read all of the charachteristics in
            for char in service.characteristics! {
                service.peripheral?.readValue(for: char)
                
                if (drinkControl.keys.contains(char.uuid)) { // Settings
                    drinkControl[char.uuid]?.charachteristic = char
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            if (drinkControl.keys.contains(characteristic.uuid)) {
                drinkControl[characteristic.uuid]?.setValue(data: characteristic.value!)
            }
    }
    
    func writeControls() {
        for (_, setting) in drinkControl {
            selectedDevice?.writeValue(setting.getData(), for: setting.charachteristic!, type: .withResponse)
        }
    }
    
    func writeControl(for uuid: CBUUID) {
        let setting = drinkControl[uuid]!
        selectedDevice?.writeValue(setting.getData(), for: setting.charachteristic!, type: .withResponse)
    }
    
    func scanForDevices() {
        if centralManager?.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: [
                DRINK_SERVICE
            ])
        }
    }
    
    func cancelPour() {
        for (_, controlChar) in drinkChars.enumerated() {
            var char = drinkControl[controlChar] as! FloatAttribute
            char.value = 0.0
        }
        
        writeControls()
    }
}
