//
//  CoffeeShopsListView.swift
//  CoffeeShopAppleWatch Watch App
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

struct CoffeeShopsListView: View {
    private let viewModel: CoffeeShopsMapViewModel
    private let container: DIContainer

    init(
        viewModel: CoffeeShopsMapViewModel,
        container: DIContainer
    ) {
        self.viewModel = viewModel
        self.container = container
    }
    
    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 5)) { context in
                List(viewModel.state.mapPlaces) { shop in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(shop.name)
                                .font(.headline)
                            Spacer()
                            Text("\(shop.rating)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(shop.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Coffee Shops")
        }
        .onAppear() {
            viewModel.fetchCoffeeShops()
        }
        .task {
            await startPeriodicViewUpdates()
        }
    }
    
    func startPeriodicViewUpdates() async {
        while true {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            viewModel.fetchCoffeeShops()
        }
    }
}
