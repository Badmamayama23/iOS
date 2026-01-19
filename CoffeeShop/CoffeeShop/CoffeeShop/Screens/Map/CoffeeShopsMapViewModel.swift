//
//  CoffeeShopsMapViewModel.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI
import CoreLocation

@Observable
class CoffeeShopsMapViewModel: ObservableObject {
    var state: CoffeeShopsMapViewState = CoffeeShopsMapViewState()
    
    private var dataManager: DataManaging
    private var locationManager: LocationManaging
    private var periodicUpdatesRunning = false
    
    init(
        dataManager: DataManaging,
        locationManager: LocationManaging
    ) {
        self.dataManager = dataManager
        self.locationManager = locationManager
    }
}

extension CoffeeShopsMapViewModel {
    func addNewCoffeeShop(shop: CoffeeShopPlace) {
        let coffeeShop = CoffeeShop(context: dataManager.context)
        
        coffeeShop.id = shop.id
        coffeeShop.name = shop.name
        coffeeShop.type = shop.type.rawValue
        coffeeShop.rating = Int16(shop.rating)
        coffeeShop.address = shop.address
        coffeeShop.latitude = shop.coordinates.latitude
        coffeeShop.longitude = shop.coordinates.longitude
        
        dataManager.saveCoffeeShop(shop: coffeeShop)
    }
    
    func fetchCoffeeShops() {
        let coffeeShops: [CoffeeShop] = dataManager.fetchCoffeeShops()
        
        state.mapPlaces = coffeeShops.map {
            CoffeeShopPlace(
                id: $0.id ?? UUID(),
                name: $0.name ?? "No Name",
                type: CoffeeShopType(rawValue: $0.type) ?? .cafeteria,
                rating: Int($0.rating),
                address: $0.address ?? "",
                coordinates: .init(latitude: $0.latitude, longitude: $0.longitude ))
        }
    }
    
    func removeCoffeeShop(shop: CoffeeShopPlace) {
        if let coreDataShop = dataManager.fetchCoffeeShopWithId(id: shop.id) {
            dataManager.removeCoffeeShop(shop: coreDataShop)
            fetchCoffeeShops()
        } else {
            print("Cannot fetch CoffeeShop with given id")
        }
    }
    
    func syncLocation() {
        #if os(iOS)
        state.mapCameraPosition = locationManager.cameraPosition
        #endif
        state.currentLocation = locationManager.currentLocation
    }
    
    func startPeriodicLocationUpdate() async {
        if !periodicUpdatesRunning {
            periodicUpdatesRunning.toggle()
            
            while true {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                syncLocation()
            }
        }
    }
}
