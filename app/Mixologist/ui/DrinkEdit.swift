//
//  DrinkEdit.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI
import PhotosUI

struct DrinkEdit: View {
    var drink: Drink
    
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isPresented) var isPresented
    @EnvironmentObject var btManager: BluetoothManager
    @State private var drinkImageItem: PhotosPickerItem?
    
    @State private var drinkImageData: Data?
    @State private var drinkName: String = ""
    
    @State var ingredientNames = [String](repeating: "", count: 8)
    @State private var pourAmounts = [Int32](repeating: 0, count: 8)
    
    var body: some View {
        List {
            Section(header: Text("Drink Image")) {
                if drinkImageData != nil {
                    
                    HStack {
                        Spacer()
                        Image(data: drinkImageData!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .clipShape(.rect(cornerRadius: 16))
                        Spacer()

                    }
                }
                
                PhotosPicker(selection: $drinkImageItem, matching: .images) {
                    Text("Select Drink Image")
                }
                    .padding(.horizontal, 16)
                    .onChange(of: drinkImageItem) {
                        Task {
                            if let loaded = try? await drinkImageItem?.loadTransferable(type: Data.self) {
                                drinkImageData = loaded
                            } else {
                                print("Failed")
                            }
                        }
                    }
            }
                        
            Section(header: Text("Name")) {
                TextField("Name", text: $drinkName)
            }
            
            Section(header: Text("Pour Amounts")) {
                ForEach(0..<8) { i in
                    LabeledContent {
                        TextField("Amount", value: $pourAmounts[i], format: .number)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Text(ingredientNames[i] == ""
                             ? "Tube " + String(i+1)
                             : ingredientNames[i])
                    }
                }
            }
        }
            .interactiveDismissDisabled()
            .onAppear {
                if drink.image != nil {
                    drinkImageData = drink.image
                }
                
                drinkName = drink.name
                
                for (i, _) in pourAmounts.enumerated() {
                    pourAmounts[i] = drink.dispenseAmounts[i]
                    print(drink.dispenseAmounts[i])
                }
                
                if let savedNames = UserDefaults.standard.array(forKey: "ingredient_names") {
                    ingredientNames = savedNames as! [String]
                }
            }
            .onChange(of: isPresented) {
                if !isPresented {
                    drink.name = drinkName
                    drink.image = drinkImageData
                    
                    for (i, _) in pourAmounts.enumerated() {
                        drink.dispenseAmounts[i] = pourAmounts[i]
                    }
                    try! modelContext.save()
                }
            }
            .navigationTitle("Edit")
    }
}
