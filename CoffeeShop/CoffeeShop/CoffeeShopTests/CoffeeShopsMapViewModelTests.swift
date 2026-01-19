//
//  CoffeeShopsMapViewModelTests.swift
//  CoffeeShopTests
//
//  Created by Matej Šalka on 18/01/2026.
//

import CoreData
import XCTest
import MapKit
@testable import CoffeeShop

final class CoffeeShopsMapViewModelTests: XCTestCase {
    private var persistentContainer: NSPersistentContainer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        persistentContainer = NSPersistentContainer(name: "CoffeeShop")
        let description = NSPersistentStoreDescription()
        // In memory setup
        description.url = URL(fileURLWithPath: "/dev/null")
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }
    
    override func tearDownWithError() throws {
        persistentContainer = nil
        try super.tearDownWithError()
    }
    
    // Test 1: Valid address (normal street address)
    func testAddNewCoffeeShopWithValidAddress() throws {
        let sut = createSUT()
        let validAddress = "123 Main Street, Brno, Czech Republic"
        
        let newCoffeeShop = CoffeeShopPlace(
            id: UUID(),
            name: "Test Coffee Shop",
            type: .coffeeShop,
            rating: 5,
            address: validAddress,
            coordinates: CLLocationCoordinate2D(latitude: 49.21044343932761, longitude: 16.6157301199077)
        )
        
        sut.addNewCoffeeShop(shop: newCoffeeShop)
        sut.fetchCoffeeShops()
        
        XCTAssertFalse(sut.state.mapPlaces.isEmpty, "Coffee shop should be added")
        let addedShop = try XCTUnwrap(sut.state.mapPlaces.first, "First coffee shop should exist")
        XCTAssertEqual(addedShop.address, validAddress, "Address should match")
        XCTAssertEqual(addedShop.name, "Test Coffee Shop", "Name should match")
    }
    
    // Test 2: Invalid address (empty string)
    func testAddNewCoffeeShopWithEmptyAddress() throws {
        let sut = createSUT()
        let emptyAddress = ""
        
        let newCoffeeShop = CoffeeShopPlace(
            id: UUID(),
            name: "Test Coffee Shop",
            type: .coffeeShop,
            rating: 5,
            address: emptyAddress,
            coordinates: CLLocationCoordinate2D(latitude: 49.21044343932761, longitude: 16.6157301199077)
        )
        
        sut.addNewCoffeeShop(shop: newCoffeeShop)
        sut.fetchCoffeeShops()
        
        XCTAssertFalse(sut.state.mapPlaces.isEmpty, "Coffee shop should be added even with empty address")
        let addedShop = try XCTUnwrap(sut.state.mapPlaces.first, "First coffee shop should exist")
        XCTAssertEqual(addedShop.address, emptyAddress, "Address should be empty string")
    }
    
    // Test 3: Invalid address (whitespace only)
    func testAddNewCoffeeShopWithWhitespaceOnlyAddress() throws {
        let sut = createSUT()
        let whitespaceAddress = "   "
        
        let newCoffeeShop = CoffeeShopPlace(
            id: UUID(),
            name: "Test Coffee Shop",
            type: .coffeeShop,
            rating: 5,
            address: whitespaceAddress,
            coordinates: CLLocationCoordinate2D(latitude: 49.21044343932761, longitude: 16.6157301199077)
        )
        
        sut.addNewCoffeeShop(shop: newCoffeeShop)
        sut.fetchCoffeeShops()
        
        XCTAssertFalse(sut.state.mapPlaces.isEmpty, "Coffee shop should be added even with whitespace address")
        let addedShop = try XCTUnwrap(sut.state.mapPlaces.first, "First coffee shop should exist")
        XCTAssertEqual(addedShop.address, whitespaceAddress, "Address should match whitespace string")
    }
}

// MARK: SUT
private extension CoffeeShopsMapViewModelTests {
    func createSUT() -> CoffeeShopsMapViewModel {
        CoffeeShopsMapViewModel(
            dataManager: CoreDataManager(container: persistentContainer),
            locationManager: LocationManagerMock()
        )
    }
}
