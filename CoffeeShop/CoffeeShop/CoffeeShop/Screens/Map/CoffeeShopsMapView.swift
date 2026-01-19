//
//  CoffeeShopsMapView.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI
import MapKit

struct CoffeeShopsMapView: View {
    @State private var viewModel: CoffeeShopsMapViewModel
    @State private var isDetailPresented = false
    @State private var isNewPlaceViewPresented = false

    @EnvironmentObject var container: DIContainer

    init(viewModel: CoffeeShopsMapViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            mapView
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Add Place") {
                            isNewPlaceViewPresented.toggle()
                        }
                        .accessibilityIdentifier(.mapViewAddPlaceButton)
                    }
                }
                .sheet(isPresented: $isDetailPresented) {
                    if let selectedShop = viewModel.state.selectedCoffeeShop {
                        detailView(selectedShop: selectedShop)
                    }
                }
                .sheet(isPresented: $isNewPlaceViewPresented) {
                    NavigationStack {
                        AddCoffeeShopView(
                            isViewPresented: $isNewPlaceViewPresented,
                            viewModel: viewModel
                        )
                    }
                }
                .onAppear() {
                    viewModel.fetchCoffeeShops()
                    viewModel.syncLocation()

                    Task {
                        await viewModel.startPeriodicLocationUpdate()
                    }
                }
                .navigationTitle("Map")
        }
    }
}

private extension CoffeeShopsMapView {
    var mapView: some View {
        Map(
            position: $viewModel.state.mapCameraPosition,
            interactionModes: [.pan, .zoom]
        ) {
            // User location
            if let userLocation = viewModel.state.currentLocation {
                UserAnnotation()
            }
            
            // Coffee shop pins
            ForEach(viewModel.state.mapPlaces) { shop in
                Annotation(
                    "",
                    coordinate: shop.coordinates
                ) {
                    VStack {
                        CoffeeShopPinView()
                        
                        VStack {
                            Text(shop.name)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                            Text(shop.type.name)
                                .font(.footnote)
                        }
                        .padding(5.0)
                        .background(.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 5.0), style: FillStyle())
                    }
                    .onTapGesture {
                        viewModel.state.selectedCoffeeShop = shop
                        isDetailPresented = true
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 50))
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    func detailView(selectedShop: CoffeeShopPlace) -> some View {
        NavigationStack {
            CoffeeShopDetailView(
                viewModel: CoffeeShopDetailViewModel(
                    coffeeShop: selectedShop
                )
            )
        }
        .presentationDetents([.fraction(0.3), .medium, .large])
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Close") {
                    isDetailPresented = false
                }
            }
        }
    }
}
