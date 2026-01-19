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
        // Parse the received coffee shop data
        guard let idString = message["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = message["name"] as? String,
              let typeRawValue = message["type"] as? Int16,
              let rating = message["rating"] as? Int,
              let address = message["address"] as? String,
              let latitude = message["latitude"] as? Double,
              let longitude = message["longitude"] as? Double else {
            print("Failed to parse coffee shop message")
            return
        }
        
        // Create CoffeeShop CoreData entity and save
        addNewCoffeeShop(
            id: id,
            name: name,
            type: typeRawValue,
            rating: Int16(rating),
            address: address,
            latitude: latitude,
            longitude: longitude
        )
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
