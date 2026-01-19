//
//  PhoneConnecting.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import WatchConnectivity

#if os(watchOS)
protocol PhoneConnecting {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any])
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any])
}
#endif
