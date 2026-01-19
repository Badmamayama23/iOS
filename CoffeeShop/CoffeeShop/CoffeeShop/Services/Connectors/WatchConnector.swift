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
        if session.isReachable {
            let message: [String: Any] = [
                "id": shop.id.uuidString,
                "name": shop.name,
                "type": shop.type.rawValue,
                "rating": shop.rating,
                "address": shop.address,
                "latitude": shop.coordinates.latitude,
                "longitude": shop.coordinates.longitude
            ]
            
            session.sendMessage(message, replyHandler: nil) { error in
                print("Sending error: \(error.localizedDescription)")
            }
        } else {
            print("Session is not reachable")
        }
    }
}
#endif
