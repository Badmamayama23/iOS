//
//  WatchConnector.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import Foundation
import WatchConnectivity

#if os(iOS)
class WatchConnector: NSObject, WCSessionDelegate, WatchConnecting {
    
    private var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func sendCoffeeShop(shop: CoffeeShopPlace) {
        let message = coffeeShopPayload(from: shop)
        
        if session.activationState != .activated {
            session.activate()
        }
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { [weak self] error in
                print("Sending error: \(error.localizedDescription)")
                self?.queueCoffeeShopPayload(message)
            }
        } else {
            queueCoffeeShopPayload(message)
        }
    }
}

private extension WatchConnector {
    func coffeeShopPayload(from shop: CoffeeShopPlace) -> [String: Any] {
        [
            "id": shop.id.uuidString,
            "name": shop.name,
            "type": Int(shop.type.rawValue),
            "rating": shop.rating,
            "address": shop.address,
            "latitude": shop.coordinates.latitude,
            "longitude": shop.coordinates.longitude
        ]
    }
    
    func queueCoffeeShopPayload(_ payload: [String: Any]) {
        session.transferUserInfo(payload)
    }
}
#endif
