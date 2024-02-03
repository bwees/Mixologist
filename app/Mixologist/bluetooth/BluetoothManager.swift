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
    
    @Published var slotControls: [CBUUID: any GATTAttribute] = [
        SLOT_1_CTRL: IntAttribute(name: "Slot 1"),
        SLOT_2_CTRL: IntAttribute(name: "Slot 2"),
        SLOT_3_CTRL: IntAttribute(name: "Slot 3"),
        SLOT_4_CTRL: IntAttribute(name: "Slot 4"),
        SLOT_5_CTRL: IntAttribute(name: "Slot 5"),
        SLOT_6_CTRL: IntAttribute(name: "Slot 6"),
        SLOT_7_CTRL: IntAttribute(name: "Slot 7"),
        SLOT_8_CTRL: IntAttribute(name: "Slot 8")
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
                peripheral.setNotifyValue(true, for: char)
                
                if (slotControls.keys.contains(char.uuid)) { // Settings
                    slotControls[char.uuid]?.charachteristic = char
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (slotControls.keys.contains(characteristic.uuid)) {
            slotControls[characteristic.uuid]?.setValue(data: characteristic.value!)
        }
    }
    
    func writeControls() {
        for (_, control) in slotControls {
            selectedDevice?.writeValue(control.getData(), for: control.charachteristic!, type: .withResponse)
        }
    }
    
    func writeControl(for uuid: CBUUID) {
        let control = slotControls[uuid]!
        selectedDevice?.writeValue(control.getData(), for: control.charachteristic!, type: .withResponse)
    }
    
    func scanForDevices() {
        if centralManager?.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: [
                DRINK_SERVICE
            ])
        }
    }
    
    func getProgress() -> [Int32] {
        var progresses = [Int32](repeating: 0, count: 8)
        
        var i = 0
        for char in slotCharArray {
            var intSetting = slotControls[char] as! IntAttribute
            
            progresses[i] = intSetting.value ?? 0
            i += 1
        }
        
        return progresses
    }
    
    
    func cancelPour() {
        for controlChar in slotCharArray {
            let char = slotControls[controlChar] as! IntAttribute
            char.value = 0
        }
        
        writeControls()
    }
}
