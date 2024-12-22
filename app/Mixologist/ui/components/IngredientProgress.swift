//
//  LabeledTextView.swift
//  hoverwheel
//
//  Created by Brandon Wees on 1/17/24.
//

import SwiftUI

struct IngredientProgress: View {
    @ObservedObject var ingredient: IntAttribute

    var body: some View {
        LabeledContent {
            if ingredient.value != nil {
                Text(String(ingredient.value!))
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        } label: {
            Text(ingredient.name)
        }
    }
}
