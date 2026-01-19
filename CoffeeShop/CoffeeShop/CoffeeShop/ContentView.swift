//
//  ContentView.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

struct ContentView: View {
    private let container = DIContainer.shared

    var body: some View {
        CoffeeShopsMapView(
            viewModel: CoffeeShopsMapViewModel(
                dataManager: container.resolve(),
                locationManager: container.resolve()
            )
        )
        .environmentObject(container)
    }
}

//#Preview {
//    ContentView()
//}
