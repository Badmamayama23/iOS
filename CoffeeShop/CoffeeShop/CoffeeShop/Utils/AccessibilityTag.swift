//
//  AccessibilityTag.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import Foundation
import SwiftUI

enum AccessibilityTag: String {
    // MapView
    case mapViewMap
    case mapViewAddPlaceButton
    case mapViewAnnotationContent
    
    // AddCoffeeShopView
    case addCoffeeShopNameTextField
    case addCoffeeShopAddressTextField
    case addCoffeeShopCancelButton
    case addCoffeeShopSaveButton
    
    // DetailView
    case detailViewTitle
    case detailViewName
    case detailViewType
    case detailViewAddress
    case detailViewRating
}

extension View {
    func accessibilityIdentifier(_ tag: AccessibilityTag) -> some View {
        self.accessibilityIdentifier(tag.rawValue)
    }
}
