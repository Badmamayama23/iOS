//
//  StarRatingView.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Int
    @State private var showStars: [Bool] = [false, false, false, false, false]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .opacity(showStars[index] ? 1.0 : 0.0)
                    .scaleEffect(showStars[index] ? 1.0 : 0.3)
                    .offset(x: showStars[index] ? 0 : -20)
            }
        }
        .onAppear {
            animateStars()
        }
    }
    
    private func animateStars() {
        for index in 0..<5 {
            withAnimation(
                .spring(response: 0.5, dampingFraction: 0.6)
                .delay(Double(index) * 0.1)
            ) {
                showStars[index] = true
            }
        }
    }
}
