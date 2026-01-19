//
//  CoffeeShopDetailViewState.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import Observation

@Observable
final class CoffeeShopDetailViewState {
    var coffeeShop: CoffeeShopPlace
    
    init(coffeeShop: CoffeeShopPlace) {
        self.coffeeShop = coffeeShop
    }
}
