#include <ArduinoBLE.h>
#include "config.h"

BLEService drinkService("523ed38f-e856-45e7-9a6e-ec9e51c3aba1"); // create service

BLEIntCharacteristic ingredient1Char("19b10001-e8f2-537e-4f6c-d104768a1214", BLEWrite | BLENotify | BLERead);
BLEIntCharacteristic ingredient2Char("29b10001-e8f2-537e-4f6c-d104768a1214", BLEWrite | BLENotify | BLERead);
BLEIntCharacteristic ingredient3Char("39b10001-e8f2-537e-4f6c-d104768a1214", BLEWrite | BLENotify | BLERead);
BLEIntCharacteristic ingredient4Char("49b10001-e8f2-537e-4f6c-d104768a1214", BLEWrite | BLENotify | BLERead);
BLEIntCharacteristic ingredient5Char("59b10001-e8f2-537e-4f6c-d104768a1214", BLEWrite | BLENotify | BLERead);
BLEIntCharacteristic ingredient6Char("69b10001-e8f2-537e-4f6c-d104768a1214", BLEWrite | BLENotify | BLERead);
BLEIntCharacteristic ingredient7Char("79b10001-e8f2-537e-4f6c-d104768a1214", BLEWrite | BLENotify | BLERead);
BLEIntCharacteristic ingredient8Char("89b10001-e8f2-537e-4f6c-d104768a1214", BLEWrite | BLENotify | BLERead);

BLEIntCharacteristic ingredients[8] = {ingredient1Char, ingredient2Char, ingredient3Char, ingredient4Char, ingredient5Char, ingredient6Char, ingredient7Char, ingredient8Char};

int uuidToIndex(String uuid) {
    if (uuid == "19b10001-e8f2-537e-4f6c-d104768a1214") {
        return 0;
    } else if (uuid == "29b10001-e8f2-537e-4f6c-d104768a1214") {
        return 1;
    } else if (uuid == "39b10001-e8f2-537e-4f6c-d104768a1214") {
        return 2;
    } else if (uuid == "49b10001-e8f2-537e-4f6c-d104768a1214") {
        return 3;
    } else if (uuid == "59b10001-e8f2-537e-4f6c-d104768a1214") {
        return 4;
    } else if (uuid == "69b10001-e8f2-537e-4f6c-d104768a1214") {
        return 5;
    } else if (uuid == "79b10001-e8f2-537e-4f6c-d104768a1214") {
        return 6;
    } else if (uuid == "89b10001-e8f2-537e-4f6c-d104768a1214") {
        return 7;
    }

    return 0;
}

BLEIntCharacteristic uuidToChar(String uuid) {
    if (uuid == "19b10001-e8f2-537e-4f6c-d104768a1214") {
        return ingredient1Char;
    } else if (uuid == "29b10001-e8f2-537e-4f6c-d104768a1214") {
        return ingredient2Char;
    } else if (uuid == "39b10001-e8f2-537e-4f6c-d104768a1214") {
        return ingredient3Char;
    } else if (uuid == "49b10001-e8f2-537e-4f6c-d104768a1214") {
        return ingredient4Char;
    } else if (uuid == "59b10001-e8f2-537e-4f6c-d104768a1214") {
        return ingredient5Char;
    } else if (uuid == "69b10001-e8f2-537e-4f6c-d104768a1214") {
        return ingredient6Char;
    } else if (uuid == "79b10001-e8f2-537e-4f6c-d104768a1214") {
        return ingredient7Char;
    } else if (uuid == "89b10001-e8f2-537e-4f6c-d104768a1214") {
        return ingredient8Char;
    }

    return ingredient1Char;
}

void blePeripheralConnectHandler(BLEDevice central) {
    // central connected event handler
    Serial.print("Connected event, central: ");
    Serial.println(central.address());
}

void blePeripheralDisconnectHandler(BLEDevice central) {
    // central disconnected event handler
    Serial.print("Disconnected event, central: ");
    Serial.println(central.address());
}

void setup_ble(BLECharacteristicEventHandler pourHandler) {
    // begin initialization
    if (!BLE.begin()) {
        while (1);
    }

    BLE.setLocalName("Mixologist");
    BLE.setDeviceName("Mixologist ");

    // BLE
    BLE.setAdvertisedService(drinkService);

    // add the characteristic to the service
    drinkService.addCharacteristic(ingredient1Char);
    drinkService.addCharacteristic(ingredient2Char);
    drinkService.addCharacteristic(ingredient3Char);
    drinkService.addCharacteristic(ingredient4Char);
    drinkService.addCharacteristic(ingredient5Char);
    drinkService.addCharacteristic(ingredient6Char);
    drinkService.addCharacteristic(ingredient7Char);
    drinkService.addCharacteristic(ingredient8Char);

    // add service
    BLE.addService(drinkService);

    // assign event handlers for connected, disconnected to peripheral
    BLE.setEventHandler(BLEConnected, blePeripheralConnectHandler);
    BLE.setEventHandler(BLEDisconnected, blePeripheralDisconnectHandler);

    // start advertising
    BLE.advertise();

    // assign event handlers for characteristic
    ingredient1Char.setEventHandler(BLEWritten, pourHandler);
    ingredient2Char.setEventHandler(BLEWritten, pourHandler);
    ingredient3Char.setEventHandler(BLEWritten, pourHandler);
    ingredient4Char.setEventHandler(BLEWritten, pourHandler);
    ingredient5Char.setEventHandler(BLEWritten, pourHandler);
    ingredient6Char.setEventHandler(BLEWritten, pourHandler);
    ingredient7Char.setEventHandler(BLEWritten, pourHandler);
    ingredient8Char.setEventHandler(BLEWritten, pourHandler);
}