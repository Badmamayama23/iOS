//
//  CoffeeShopType.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import Foundation

enum CoffeeShopType: Int16, CaseIterable, Identifiable {
    var id: Self { self }
    
    case cafeteria = 0
    case coffeeShop = 1
    case teaShop = 2
    
    var name: String {
        let key = String(describing: self)
        return NSLocalizedString(
            key,
            comment: "The name of the location type"
        )
    }
}
