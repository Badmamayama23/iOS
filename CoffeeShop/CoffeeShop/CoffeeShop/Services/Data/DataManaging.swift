//
//  DataManaging.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import CoreData

protocol DataManaging {
    var context: NSManagedObjectContext { get }
    
    func saveCoffeeShop(shop: CoffeeShop)
    func removeCoffeeShop(shop: CoffeeShop)
    func fetchCoffeeShops() -> [CoffeeShop]
    func fetchCoffeeShopWithId(id: UUID) -> CoffeeShop?
}
