//
//  AddCoffeeShopView.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI
import CoreLocation

struct AddCoffeeShopView: View {
    @Binding var isViewPresented: Bool
    @State var viewModel: CoffeeShopsMapViewModel
    
    @State private var shopName: String = ""
    @State private var shopType: CoffeeShopType = .coffeeShop
    @State private var shopRating: Int = 3
    @State private var shopAddress: String = ""
    @State private var shopLocation: CLLocationCoordinate2D = .init()

    var body: some View {
        Form {
            Section(content: {
                TextField("", text: $shopName)
                    .accessibilityIdentifier(.addCoffeeShopNameTextField)
            }, header: {
                Text("Name")
            })
            
            Section("Details") {
                Picker(selection: $shopType) {
                    ForEach(CoffeeShopType.allCases) { option in
                        Text(option.name).tag(option)
                    }
                } label: {
                    Text("Type")
                }
                .pickerStyle(.menu)
                
                Picker(selection: $shopRating) {
                    ForEach(1...5, id: \.self) { rating in
                        Text("\(rating)").tag(rating)
                    }
                } label: {
                    Text("Rating")
                }
                .pickerStyle(.menu)
                
                TextField("", text: $shopAddress)
                    .accessibilityIdentifier(.addCoffeeShopAddressTextField)
                    .placeholder(when: shopAddress.isEmpty) {
                        Text("Address").foregroundColor(.gray)
                    }
            }
        }
        .onAppear {
            viewModel.syncLocation()
            shopLocation = viewModel.state.currentLocation ?? .init()
        }
        .navigationTitle("Add Place")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Cancel") {
                    isViewPresented.toggle()
                }
                .accessibilityIdentifier(.addCoffeeShopCancelButton)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Save") {
                    saveCoffeeShop()
                    isViewPresented.toggle()
                }
                .disabled(shopName.isEmpty || shopAddress.isEmpty)
                .accessibilityIdentifier(.addCoffeeShopSaveButton)
            }
        }
    }
    
    private func saveCoffeeShop() {
        let newCoffeeShop = CoffeeShopPlace(
            id: UUID(),
            name: shopName,
            type: shopType,
            rating: shopRating,
            address: shopAddress,
            coordinates: shopLocation
        )
        
        viewModel.addNewCoffeeShop(shop: newCoffeeShop)
        viewModel.fetchCoffeeShops()
        
        // Send to Apple Watch
        #if os(iOS)
        let connector: WatchConnecting = DIContainer.shared.resolve()
        connector.sendCoffeeShop(shop: newCoffeeShop)
        #endif
    }
}

// Helper extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
