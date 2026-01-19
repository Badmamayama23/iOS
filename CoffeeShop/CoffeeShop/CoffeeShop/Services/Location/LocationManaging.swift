//
//  LocationManaging.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import MapKit
import SwiftUI

protocol LocationManaging {
    var cameraPosition: MapCameraPosition { get }
    var currentLocation: CLLocationCoordinate2D? { get }
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double?
}
