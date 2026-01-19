//
//  CoffeeShopApp.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

@main
struct CoffeeShopApp: App {
    var body: some Scene {
        WindowGroup {
            CoffeeShopsMapView(
                viewModel: CoffeeShopsMapViewModel(
                    dataManager: DIContainer.shared.resolve(),
                    locationManager: DIContainer.shared.resolve()
                )
            )
            .environmentObject(DIContainer.shared)
        }
    }
}
