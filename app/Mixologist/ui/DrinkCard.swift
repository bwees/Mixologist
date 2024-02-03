//
//  DrinkCard.swift
//  Mixologist
//
//  Created by Brandon Wees on 2/2/24.
//

import SwiftUI

struct DrinkCard: View {
    var drink: Drink
    
    @State var isPouring = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if drink.image != nil {
                    
                    Image(data: drink.image!)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height-48,
                            alignment: .center
                        )
                        .clipped()
                        .clipShape(.rect(cornerRadius: 16))
                } else {
                    VStack {
                        Image(systemName: "photo.badge.plus")
                            .font(.largeTitle)
                        Text("Add an image in settings")

                    }
                }
                        
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Text(drink.name)
                                .font(.largeTitle.bold())
                        }
                        Spacer()
                        VStack {
                            Button(action: {
                                isPouring = true
                            }) {
                                Text("Pour")
                                    .font(.title2.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                                .buttonStyle(.borderedProminent)
                        }
                        
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(.thinMaterial)
                    .clipped()
                    .clipShape(.rect(cornerRadii: RectangleCornerRadii(bottomLeading: 16, bottomTrailing: 16)))
                }
                
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $isPouring) {
            PourProgress(drinkID: drink.id)
        }
    }
}

