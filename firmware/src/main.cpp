#include <Arduino.h>
#include "ble.h"
#include <map>

int futures[8] = {-1};
int lastBLE = millis();

void handleIngredientPour(BLEDevice central, BLECharacteristic characteristic) {
    BLEIntCharacteristic c = uuidToChar(characteristic.uuid());
    int index = uuidToIndex(characteristic.uuid());

    if (c.value() == 0) {
        Serial.print("Stop pouring ingredient: ");
        Serial.println(index);

        futures[index] = -1;
        digitalWrite(pins[index], LOW);
        return;
    }

    Serial.print("Start pouring ingredient: ");
    Serial.println(index);

    Serial.println("Pin: " + String(pins[index]));
    digitalWrite(pins[index], HIGH);

    futures[index] = millis() + c.value();
}


void setup() {
    Serial.begin(9600);
    setup_ble(handleIngredientPour);

    for (int i = 0; i < 8; i++) {
        pinMode(pins[i], OUTPUT);
        digitalWrite(pins[i], LOW);
    }
}

void loop() {
    BLE.poll();
    
    for (int i = 0; i < 8; i++) {
        if (futures[i] != -1 && millis() > futures[i]) {
            Serial.print("Stop pouring ingredient: ");
            Serial.println(i);

            digitalWrite(pins[i], LOW);
            futures[i] = -1;
        }

        if (millis() - lastBLE > 500) {
            if (futures[i] != -1 && futures[i] - millis() > 0) {
                BLEIntCharacteristic c = ingredients[i];
                c.writeValue(futures[i] - millis());
                Serial.print("Ingredient ");
                Serial.print(i);
                Serial.print(" pour time remaining: ");
                Serial.println(futures[i] - millis());
            } else {
                BLEIntCharacteristic c = ingredients[i];
                if (c.value() != 0) {
                    c.writeValue(0);   
                }
            }
        }
    }

    if (millis() - lastBLE > 500) {
        lastBLE = millis();
    }

    delay(10);
}