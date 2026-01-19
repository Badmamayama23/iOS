//
//  CoffeeShop.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import Foundation
import CoreLocation

struct CoffeeShopPlace: Identifiable {
    var id: UUID
    var name: String
    var type: CoffeeShopType
    var rating: Int  // 1-5
    var address: String
    var coordinates: CLLocationCoordinate2D
    
    static let sample1 = CoffeeShopPlace(
        id: UUID(),
        name: "Coffee Corner",
        type: .cafeteria,
        rating: 4,
        address: "123 Main Street, Brno",
        coordinates: .init(latitude: 49.21044343932761, longitude: 16.61573011990775)
    )
    
    static let sample2 = CoffeeShopPlace(
        id: UUID(),
        name: "Tea Time",
        type: .teaShop,
        rating: 5,
        address: "456 Second Avenue, Brno",
        coordinates: .init(latitude: 49.20726827756502, longitude: 16.61617000220887)
    )
    
    static let samples = [sample1, sample2]
}
