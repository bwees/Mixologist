//
//  ContentView.swift
//  Mixologist
//
//  Created by Brandon Wees on 1/30/24.
//

import SwiftUI
import SwiftData

struct Settings: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Drink]
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            
                List {
                    ForEach(items) { drink in
                        NavigationLink {
                            DrinkEdit(drink: drink)
                        } label: {
                            Text(drink.name)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            addItem()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Drink(name: "new drink")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Drink.self, inMemory: true)
}
