//
//  CoreDataManager.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import CoreData

final class CoreDataManager: DataManaging {
    private let container: NSPersistentContainer
    
    var context: NSManagedObjectContext{
        container.viewContext
    }
    
    init(container: NSPersistentContainer = NSPersistentContainer(name: "CoffeeShop")) {
            self.container = container
            container.loadPersistentStores { _, error in
                if let error = error {
                    print("Cannot create persistent store: \(error.localizedDescription)")
                }
            }
        }
    
    func saveCoffeeShop(shop: CoffeeShop) {
        save()
    }
    
    func removeCoffeeShop(shop: CoffeeShop) {
        context.delete(shop)
        save()
    }
    
    func fetchCoffeeShops() -> [CoffeeShop] {
        let request = NSFetchRequest<CoffeeShop>(entityName: "CoffeeShop")
        var shops: [CoffeeShop] = []
        
        do {
            shops = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        return shops
    }
    
    func fetchCoffeeShopWithId(id: UUID) -> CoffeeShop? {
        let request = NSFetchRequest<CoffeeShop>(entityName: "CoffeeShop")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        var shops: [CoffeeShop] = []
                
        do {
            shops = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        return shops.first
    }
}

private extension CoreDataManager {
    private func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Cannot save MOC: \(error.localizedDescription)")
            }
        }
    }
}
