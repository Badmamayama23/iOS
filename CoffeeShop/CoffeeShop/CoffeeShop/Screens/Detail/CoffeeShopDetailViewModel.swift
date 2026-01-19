//
//  CoffeeShopDetailViewModel.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

@Observable
class CoffeeShopDetailViewModel: ObservableObject {
    var state: CoffeeShopDetailViewState
    
    init(coffeeShop: CoffeeShopPlace) {
        state = CoffeeShopDetailViewState(coffeeShop: coffeeShop)
    }
}
