//
//  ContentView.swift
//  CoffeeShopAppleWatch Watch App
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

struct ContentView: View {
    private let container = DIContainer.shared

    var body: some View {
        CoffeeShopsListView(
            viewModel: CoffeeShopsMapViewModel(
                dataManager: container.resolve() as DataManaging,
                locationManager: container.resolve() as LocationManaging
            ),
            container: container
        )
    }
}

//#Preview {
//    ContentView()
//}
