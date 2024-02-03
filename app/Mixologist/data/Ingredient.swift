//
//  Ingredient.swift
//  Mixologist
//
//  Created by Brandon Wees on 2/3/24.
//

import Foundation
import SwiftData

@Model
final class Ingredient: Codable, Identifiable, Equatable, Hashable {
    var name: String
    var id: String
    
    init(name: String) {
        self.name = name
        self.id = UUID().uuidString
    }
    
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }

    private enum CodingKeys : String, CodingKey {
        case name
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
    }
    
    func getSlotIndex() -> Int? {
        let slotConfiguration: [String] = UserDefaults.standard.array(forKey: "slotConfig")! as! [String]
        
        return slotConfiguration.firstIndex(of: self.id)
    }
    
}
