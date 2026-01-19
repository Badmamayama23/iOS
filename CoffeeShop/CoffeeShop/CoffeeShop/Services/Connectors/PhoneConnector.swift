//
//  PhoneConnector.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import Foundation
import WatchConnectivity
import CoreData

#if os(watchOS)
class PhoneConnector: NSObject, WCSessionDelegate, PhoneConnecting {
    
    private var session: WCSession
    private var dataManager: DataManaging
    
    init(session: WCSession = .default, dataManager: DataManaging) {
        self.session = session
        self.dataManager = dataManager
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleCoffeeShopPayload(message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        handleCoffeeShopPayload(userInfo)
    }
    
    private func handleCoffeeShopPayload(_ payload: [String: Any]) {
        guard let idString = payload["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = payload["name"] as? String,
              let typeNumber = payload["type"] as? NSNumber,
              let ratingNumber = payload["rating"] as? NSNumber,
              let address = payload["address"] as? String,
              let latitudeNumber = payload["latitude"] as? NSNumber,
              let longitudeNumber = payload["longitude"] as? NSNumber else {
            print("Failed to parse coffee shop payload")
            return
        }
        
        let typeRawValue = typeNumber.int16Value
        let rating = ratingNumber.int16Value
        let latitude = latitudeNumber.doubleValue
        let longitude = longitudeNumber.doubleValue
        
        dataManager.context.perform {
            if self.dataManager.fetchCoffeeShopWithId(id: id) != nil {
                return
            }
            
            self.addNewCoffeeShop(
                id: id,
                name: name,
                type: typeRawValue,
                rating: rating,
                address: address,
                latitude: latitude,
                longitude: longitude
            )
        }
    }
    
    private func addNewCoffeeShop(
        id: UUID,
        name: String,
        type: Int16,
        rating: Int16,
        address: String,
        latitude: Double,
        longitude: Double
    ) {
        let coffeeShop = CoffeeShop(context: dataManager.context)
        
        coffeeShop.id = id
        coffeeShop.name = name
        coffeeShop.type = type
        coffeeShop.rating = rating
        coffeeShop.address = address
        coffeeShop.latitude = latitude
        coffeeShop.longitude = longitude
        
        dataManager.saveCoffeeShop(shop: coffeeShop)
    }
}
#endif
