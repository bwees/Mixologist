//
//  Utils.swift
//  Mixologist
//
//  Created by Brandon Wees on 2/2/24.
//

import Foundation
import SwiftUI

extension Image {
    init(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            // If data cannot be converted to UIImage, return an empty Image
            self = Image(systemName: "photo")
            return
        }
        // Convert UIImage to SwiftUI Image
        self = Image(uiImage: uiImage)
    }
}


struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
