//
//  LocationManagerMock.swift
//  CoffeeShopTests
//
//  Created by Matej Šalka on 18/01/2026.
//

import CoreLocation
import Foundation
#if os(iOS)
import MapKit
import SwiftUI
#endif
@testable import CoffeeShop

final class LocationManagerMock: LocationManaging {
    #if os(iOS)
    var cameraPosition: MapCameraPosition
    #else
    var cameraPosition: Any
    #endif
    
    var currentLocation: CLLocationCoordinate2D?
    
    init() {
        #if os(iOS)
        cameraPosition = .automatic
        #else
        cameraPosition = "automatic"
        #endif
        currentLocation = CLLocationCoordinate2D(
            latitude: 49.21044343932761,
            longitude: 16.6157301199077
        )
    }
    
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double? {
        100
    }
}
