//
//  Ingredient.swift
//  Mixologist
//
//  Created by Brandon Wees on 2/3/24.
//

import Foundation
import SwiftData

@Model
final class Ingredient {
    var name: String
    var id: String
    
    init(name: String) {
        self.name = name
        self.id = UUID().uuidString
    }
}
