//
//  CoffeeShopPinView.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

struct CoffeeShopPinView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.brown)
            .frame(width: 30, height: 30)
            .overlay {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .shadow(radius: 5)
    }
}
