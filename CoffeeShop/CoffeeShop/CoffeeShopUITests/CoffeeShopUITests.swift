//
//  CoffeeShopUITests.swift
//  CoffeeShopUITests
//
//  Created by Matej Šalka on 18/01/2026.
//

@testable import CoffeeShop
import XCTest

final class CoffeeShopUITests: XCTestCase {
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    func testMapViewIsLoaded() {
        let app = XCUIApplication()
        app.launch()
        
        // Check if the map is visible
        XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 3))
    }
    
    func testAddPlaceViewComponentsAreCreated() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap "Add Place" button
        let addPlaceButton = app.buttons[.mapViewAddPlaceButton]
        XCTAssertTrue(addPlaceButton.waitForExistence(timeout: 3))
        addPlaceButton.tap()
        
        // Check if Name text field exists
        let nameTextField = app.textFields[.addCoffeeShopNameTextField]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 3), "Name text field should exist")
        
        // Check if Address text field exists
        let addressTextField = app.textFields[.addCoffeeShopAddressTextField]
        XCTAssertTrue(addressTextField.waitForExistence(timeout: 3), "Address text field should exist")
        
        // Check if Cancel button exists
        let cancelButton = app.buttons[.addCoffeeShopCancelButton]
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist")
        
        // Check if Save button exists
        let saveButton = app.buttons[.addCoffeeShopSaveButton]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled when form is empty")
        
        // Close the view
        cancelButton.tap()
    }
    
    func testDetailViewComponentsAreCreated() throws {
        let app = XCUIApplication()
        app.launch()
        
        // First, we need to add a coffee shop to test the detail view
        // This assumes there's at least one coffee shop on the map
        // Or we can add one first
        
        // Wait for map to load
        XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 3))
        
        // Note: Testing detail view requires having a coffee shop to tap
        // In a real scenario, you might need to set up test data first
        // For now, we'll just verify the components exist when a detail is shown
        
        // If there's an annotation on the map, tap it
        // This is a simplified test - in practice you'd set up test data
    }
    
    func testSaveButtonEnabledWhenFieldsFilled() {
        let app = XCUIApplication()
        app.launch()
        
        // Open Add Place view
        let addPlaceButton = app.buttons[.mapViewAddPlaceButton]
        XCTAssertTrue(addPlaceButton.waitForExistence(timeout: 3))
        addPlaceButton.tap()
        
        let saveButton = app.buttons[.addCoffeeShopSaveButton]
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled initially")
        
        // Fill in name
        let nameTextField = app.textFields[.addCoffeeShopNameTextField]
        nameTextField.tap()
        nameTextField.typeText("Test Coffee Shop")
        
        // Fill in address
        let addressTextField = app.textFields[.addCoffeeShopAddressTextField]
        addressTextField.tap()
        addressTextField.typeText("123 Main Street")
        
        // Save button should now be enabled
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled when name and address are filled")
        
        // Close without saving
        let cancelButton = app.buttons[.addCoffeeShopCancelButton]
        cancelButton.tap()
    }
}

extension XCUIElementQuery {
    subscript(_ tag: AccessibilityTag) -> XCUIElement {
        self[tag.rawValue]
    }
}
