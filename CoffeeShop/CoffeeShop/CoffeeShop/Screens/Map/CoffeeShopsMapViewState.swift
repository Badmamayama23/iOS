//
//  CoffeeShopsMapViewState.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import Observation
import MapKit
import SwiftUI

@Observable
final class CoffeeShopsMapViewState{
    var mapPlaces: [CoffeeShopPlace] = []
    var selectedCoffeeShop: CoffeeShopPlace?
    var currentLocation: CLLocationCoordinate2D?
    
    var mapCameraPosition: MapCameraPosition = .camera(
            .init(
                centerCoordinate: .init(
                    latitude: 49.21044343932761,
                    longitude: 16.6157301199077
                ),
                distance: 3000
            )
        )
}
