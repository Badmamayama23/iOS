//
//  CoffeeShopDetailView.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

struct CoffeeShopDetailView: View {
    @State private var viewModel: CoffeeShopDetailViewModel
    
    init(viewModel: CoffeeShopDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                RowElement(
                    title: "Name",
                    value: viewModel.state.coffeeShop.name
                )
                .accessibilityIdentifier(.detailViewName)
                
                RowElement(
                    title: "Type",
                    value: viewModel.state.coffeeShop.type.name
                )
                .accessibilityIdentifier(.detailViewType)
                
                RowElement(
                    title: "Address",
                    value: viewModel.state.coffeeShop.address
                )
                .accessibilityIdentifier(.detailViewAddress)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    StarRatingView(rating: viewModel.state.coffeeShop.rating)
                }
                .accessibilityIdentifier(.detailViewRating)
            }
        }
        .padding()
        .navigationTitle(viewModel.state.coffeeShop.name)
        .accessibilityIdentifier(.detailViewTitle)
    }
}
