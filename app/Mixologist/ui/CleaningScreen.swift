//
//  PourProgress.swift
//  Mixologist
//
//  Created by Brandon Wees on 2/2/24.
//

import SwiftUI
import SwiftData

struct CleaningScreen: View {
            
    @EnvironmentObject var btManager: BluetoothManager
    @Environment(\.dismiss) var dismiss
    @State var drinkProgress = [Int32](repeating: 0, count: 8)

    
    var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Image(systemName: "windshield.front.and.spray")
                .padding(.top, 48)
                .font(.system(size: 128).bold())
                .foregroundColor(.blue)
            Text("Cleaning Machine")
                .font(.largeTitle.bold())
                .padding(.top, 16)
                .padding(.horizontal, 24)
            Text("This will take approximately 20 seconds. Place your tubes in a source of clean water and place an empty cup under the spout.")
                .padding(.horizontal, 24)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            List {
                ForEach(0..<8) { slotIndex in
                    LabeledContent {
                        if drinkProgress[slotIndex] == 0 {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        } else {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    } label: {
                        Text("Slot " + String(slotIndex+1))
                    }

                }
            }
            
            .onAppear {
                btManager.cleanMachine()
            }
            .onReceive(timer) { input in
                drinkProgress = btManager.getProgress()
                
                if drinkProgress.allSatisfy({ $0 == 0 }) {
                    timer.upstream.connect().cancel()
                    print("Complete!")
                    dismiss()
                }
            }
            .interactiveDismissDisabled()
        }
    }
}
