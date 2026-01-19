# CoffeeShop App - Step-by-Step Guide

This guide walks through creating the CoffeeShop iOS app with Apple Watch support, following MVVM architecture with Dependency Injection.

## Prerequisites
- Xcode 15+ (iOS 17+)
- SwiftUI knowledge
- Basic understanding of CoreData, MapKit, and WatchConnectivity

---

## Phase 1: Project Setup

### Step 1: Create New Xcode Project
1. Open Xcode → File → New → Project
2. Select **iOS App**
3. Product Name: `CoffeeShop`
4. Interface: **SwiftUI**
5. Language: **Swift**
6. ✅ Check "Use Core Data" (we'll set it up manually)
7. ✅ Check "Include Tests"

### Step 2: Add Apple Watch Target
1. File → New → Target
2. Select **watchOS → App**
3. Product Name: `CoffeeShopAppleWatch Watch App`
4. Interface: **SwiftUI**
5. ✅ Check "Include Notification Scene" (optional)
6. ✅ Check "Include Complication" (optional)

### Step 3: Create Folder Structure
Create the following folder structure in the Project Navigator:

```
CoffeeShop/
├── DI/
├── Model/
├── Screens/
│   ├── Map/
│   ├── Detail/
│   ├── New Coffee Shop/
│   └── Components/
├── Services/
│   ├── Data/
│   ├── Location/
│   └── Connectors/
├── UIComponents/
└── Utils/
```

---

## Phase 2: CoreData Setup

### Step 4: Create CoreData Model
1. Right-click `CoffeeShop.xcdatamodeld` → New File → Data Model
2. Name it `CoffeeShop.xcdatamodel` (if not exists)
3. Add **CoffeeShop** entity with attributes:
   - `id`: UUID (optional)
   - `name`: String (optional)
   - `type`: Integer 16 (optional, default: 0)
   - `rating`: Integer 16 (optional, min: 1, max: 5, default: 0)
   - `address`: String (optional)
   - `latitude`: Double (optional, default: 0.0)
   - `longitude`: Double (optional, default: 0.0)
4. Set Codegen: **Class Definition**

### Step 5: Configure CoreData for Both Targets
1. Select `CoffeeShop.xcdatamodeld`
2. File Inspector → Target Membership
3. ✅ Check both **CoffeeShop** and **CoffeeShopAppleWatch Watch App**

---

## Phase 3: Dependency Injection Setup

### Step 6: Create DI Container
Create `DI/DIManager.swift`:

```swift
final class DIContainer: ObservableObject {
    typealias Resolver = () -> Any
    
    private var resolvers = [String: Resolver]()
    private var cache = [String: Any]()
    
    static let shared = DIContainer()
    
    init() {
        registerDependencies()
    }
    
    func register<T, R>(_ type: T.Type, cached: Bool = false, service: @escaping () -> R) {
        let key = String(reflecting: type)
        resolvers[key] = service
        
        if cached {
            cache[key] = service()
        }
    }
    
    func resolve<T>() -> T {
        let key = String(reflecting: T.self)
        
        if let cachedService = cache[key] as? T {
            return cachedService
        }
        
        if let resolver = resolvers[key], let service = resolver() as? T {
            return service
        }
        
        fatalError("\(key) has not been registered.")
    }
}

extension DIContainer {
    func registerDependencies() {
        register(DataManaging.self, cached: true) {
            CoreDataManager()
        }
        
        register(LocationManaging.self, cached: true) {
            LocationManager()
        }
        
        #if os(iOS)
        register(WatchConnecting.self, cached: false) {
            WatchConnector()
        }
        #endif
        
        #if os(watchOS)
        register(PhoneConnecting.self, cached: false) {
            PhoneConnector(dataManager: DIContainer.shared.resolve())
        }
        #endif
    }
}
```

**Target Membership:** Both iOS and Watch targets ✅

---

## Phase 4: Model Layer

### Step 7: Create CoffeeShopType Enum
Create `Model/CoffeeShopType.swift`:

```swift
enum CoffeeShopType: Int16, CaseIterable, Identifiable {
    var id: Self { self }
    
    case cafeteria = 0
    case coffeeShop = 1
    case teaShop = 2
    
    var name: String {
        let key = String(describing: self)
        return NSLocalizedString(key, comment: "The name of the location type")
    }
}
```

**Target Membership:** Both targets ✅

### Step 8: Create CoffeeShopPlace Domain Model
Create `Model/CoffeeShopPlace.swift`:

```swift
import CoreLocation

struct CoffeeShopPlace: Identifiable {
    var id: UUID
    var name: String
    var type: CoffeeShopType
    var rating: Int  // 1-5
    var address: String
    var coordinates: CLLocationCoordinate2D
}
```

**Target Membership:** Both targets ✅

---

## Phase 5: Service Layer

### Step 9: Create DataManaging Protocol
Create `Services/Data/DataManaging.swift`:

```swift
import CoreData

protocol DataManaging {
    var context: NSManagedObjectContext { get }
    
    func saveCoffeeShop(shop: CoffeeShop)
    func removeCoffeeShop(shop: CoffeeShop)
    func fetchCoffeeShops() -> [CoffeeShop]
    func fetchCoffeeShopWithId(id: UUID) -> CoffeeShop?
}
```

**Target Membership:** Both targets ✅

### Step 10: Create CoreDataManager
Create `Services/Data/CoreDataManager.swift`:

```swift
import CoreData

final class CoreDataManager: DataManaging {
    private let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
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
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Cannot save: \(error.localizedDescription)")
        }
    }
}
```

**Target Membership:** Both targets ✅

### Step 11: Create LocationManaging Protocol
Create `Services/Location/LocationManaging.swift`:

```swift
#if os(iOS)
import MapKit
import SwiftUI
import CoreLocation

protocol LocationManaging {
    var cameraPosition: MapCameraPosition { get }
    var currentLocation: CLLocationCoordinate2D? { get }
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double?
}
#endif

#if os(watchOS)
import CoreLocation

protocol LocationManaging {
    var cameraPosition: Any { get }
    var currentLocation: CLLocationCoordinate2D? { get }
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double?
}
#endif
```

**Target Membership:** Both targets ✅

### Step 12: Create LocationManager
Create `Services/Location/LocationManager.swift`:

```swift
#if os(iOS)
import MapKit
import SwiftUI
import CoreLocation

@Observable
final class LocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {
    private var manager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    var cameraPosition: MapCameraPosition = .camera(
        .init(
            centerCoordinate: .init(
                latitude: 49.21044343932761,
                longitude: 16.6157301199077
            ),
            distance: 3000
        )
    )
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let actLocation = locations.last {
            let coords = actLocation.coordinate
            cameraPosition = .camera(
                .init(
                    centerCoordinate: .init(
                        latitude: coords.latitude,
                        longitude: coords.longitude
                    ),
                    distance: 3000
                )
            )
            currentLocation = coords
        }
    }
    
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double? {
        if let actLocation = currentLocation {
            let fromLocation = CLLocation(
                latitude: actLocation.latitude,
                longitude: actLocation.longitude
            )
            let toLocation = CLLocation(
                latitude: to.latitude,
                longitude: to.longitude
            )
            return fromLocation.distance(from: toLocation)
        } else {
            return nil
        }
    }
}
#endif

#if os(watchOS)
import CoreLocation

@Observable
final class LocationManager: LocationManaging {
    var currentLocation: CLLocationCoordinate2D? = nil
    
    var cameraPosition: Any {
        return "automatic"
    }
    
    init() {
        // Minimal implementation for watchOS
    }
    
    func getCurrentDistance(to: CLLocationCoordinate2D) -> Double? {
        return nil
    }
}
#endif
```

**Target Membership:**
- iOS version: iOS target only ✅
- watchOS version: Watch target only ✅

### Step 13: Add Location Permission to Info.plist
1. Open `Info.plist` (or use target settings)
2. Add: **Privacy - Location When In Use Usage Description**
3. Value: `"We need your location to show nearby coffee shops"`

---

## Phase 6: Watch Connectivity

### Step 14: Create WatchConnecting Protocol (iOS)
Create `Services/Connectors/WatchConnecting.swift`:

```swift
#if os(iOS)
protocol WatchConnecting {
    func sendCoffeeShop(shop: CoffeeShopPlace)
}
#endif
```

**Target Membership:** iOS target only ✅

### Step 15: Create WatchConnector (iOS)
Create `Services/Connectors/WatchConnector.swift`:

```swift
#if os(iOS)
import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate, WatchConnecting {
    private var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        // Handle activation
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle inactive
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
```

**Target Membership:** iOS target only ✅

### Step 16: Create PhoneConnecting Protocol (Watch)
Create `Watch/Services/Connectors/PhoneConnecting.swift`:

```swift
#if os(watchOS)
import WatchConnectivity

protocol PhoneConnecting {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any])
}
#endif
```

**Target Membership:** Watch target only ✅

### Step 17: Create PhoneConnector (Watch)
Create `Watch/Services/Connectors/PhoneConnector.swift`:

```swift
#if os(watchOS)
import Foundation
import WatchConnectivity
import CoreData

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
        // Handle activation
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
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
```

**Target Membership:** Watch target only ✅

### Step 18: Enable WatchConnectivity Capability
**For iOS:**
1. Select iOS target → Signing & Capabilities
2. Click **+ Capability**
3. Add **Background Modes** → ✅ Remote notifications (if needed)
4. In code, ensure WatchConnectivity is properly initialized

**For Watch:**
1. Select Watch target → Signing & Capabilities
2. Ensure WatchConnectivity framework is linked

---

## Phase 7: ViewModel Layer

### Step 19: Create CoffeeShopsMapViewState
Create `Screens/Map/CoffeeShopsMapViewState.swift`:

```swift
import Observation
import MapKit
import SwiftUI

@Observable
final class CoffeeShopsMapViewState {
    var mapPlaces: [CoffeeShopPlace] = []
    var selectedCoffeeShop: CoffeeShopPlace?
    var currentLocation: CLLocationCoordinate2D?
    
    var mapCameraPosition: MapCameraPosition = .camera(
        .init(
            centerCoordinate: .init(
                latitude: 49.21044343932761,
                longitude: 16.6157301199077
            ),
            distance: 3000
        )
    )
}
```

**Target Membership:** Both targets ✅

### Step 20: Create CoffeeShopsMapViewModel
Create `Screens/Map/CoffeeShopsMapViewModel.swift`:

```swift
import SwiftUI
import CoreLocation

@Observable
class CoffeeShopsMapViewModel: ObservableObject {
    var state: CoffeeShopsMapViewState = CoffeeShopsMapViewState()
    
    private var dataManager: DataManaging
    private var locationManager: LocationManaging
    private var periodicUpdatesRunning = false
    
    init(
        dataManager: DataManaging,
        locationManager: LocationManaging
    ) {
        self.dataManager = dataManager
        self.locationManager = locationManager
    }
}

extension CoffeeShopsMapViewModel {
    func addNewCoffeeShop(shop: CoffeeShopPlace) {
        let coffeeShop = CoffeeShop(context: dataManager.context)
        coffeeShop.id = shop.id
        coffeeShop.name = shop.name
        coffeeShop.type = shop.type.rawValue
        coffeeShop.rating = Int16(shop.rating)
        coffeeShop.address = shop.address
        coffeeShop.latitude = shop.coordinates.latitude
        coffeeShop.longitude = shop.coordinates.longitude
        
        dataManager.saveCoffeeShop(shop: coffeeShop)
    }
    
    func fetchCoffeeShops() {
        let coffeeShops: [CoffeeShop] = dataManager.fetchCoffeeShops()
        
        state.mapPlaces = coffeeShops.map {
            CoffeeShopPlace(
                id: $0.id ?? UUID(),
                name: $0.name ?? "No Name",
                type: CoffeeShopType(rawValue: $0.type) ?? .cafeteria,
                rating: Int($0.rating),
                address: $0.address ?? "",
                coordinates: .init(latitude: $0.latitude, longitude: $0.longitude)
            )
        }
    }
    
    func removeCoffeeShop(shop: CoffeeShopPlace) {
        if let coreDataShop = dataManager.fetchCoffeeShopWithId(id: shop.id) {
            dataManager.removeCoffeeShop(shop: coreDataShop)
            fetchCoffeeShops()
        }
    }
    
    func syncLocation() {
        state.mapCameraPosition = locationManager.cameraPosition
        state.currentLocation = locationManager.currentLocation
    }
    
    func startPeriodicLocationUpdate() async {
        if !periodicUpdatesRunning {
            periodicUpdatesRunning.toggle()
            while true {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                syncLocation()
            }
        }
    }
}
```

**Target Membership:** Both targets ✅

### Step 21: Create Detail ViewModel & State
Create `Screens/Detail/CoffeeShopDetailViewState.swift`:

```swift
import Observation

@Observable
final class CoffeeShopDetailViewState {
    var coffeeShop: CoffeeShopPlace
    
    init(coffeeShop: CoffeeShopPlace) {
        self.coffeeShop = coffeeShop
    }
}
```

Create `Screens/Detail/CoffeeShopDetailViewModel.swift`:

```swift
import SwiftUI

@Observable
class CoffeeShopDetailViewModel: ObservableObject {
    var state: CoffeeShopDetailViewState
    
    init(coffeeShop: CoffeeShopPlace) {
        state = CoffeeShopDetailViewState(coffeeShop: coffeeShop)
    }
}
```

**Target Membership:** iOS target only ✅

---

## Phase 8: UI Components

### Step 22: Create CoffeeShopPinView
Create `UIComponents/CoffeeShopPinView.swift`:

```swift
import SwiftUI

struct CoffeeShopPinView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.brown)
            .frame(width: 30, height: 30)
            .overlay {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .shadow(radius: 5)
    }
}
```

**Target Membership:** iOS target only ✅

### Step 23: Create StarRatingView
Create `UIComponents/StarRatingView.swift`:

```swift
import SwiftUI

struct StarRatingView: View {
    let rating: Int
    @State private var showStars: [Bool] = [false, false, false, false, false]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .opacity(showStars[index] ? 1.0 : 0.0)
                    .offset(x: showStars[index] ? 0 : -20)
            }
        }
        .onAppear {
            animateStars()
        }
    }
    
    private func animateStars() {
        for index in 0..<5 {
            withAnimation(.easeOut(duration: 0.3).delay(Double(index) * 0.1)) {
                showStars[index] = true
            }
        }
    }
}
```

**Target Membership:** iOS target only ✅

### Step 24: Create RowElement Component
Create `Screens/Detail/Components/RowElement.swift`:

```swift
import SwiftUI

struct RowElement: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
```

**Target Membership:** iOS target only ✅

---

## Phase 9: Views

### Step 25: Create CoffeeShopsMapView
Create `Screens/Map/CoffeeShopsMapView.swift` (see existing implementation)

**Target Membership:** iOS target only ✅

### Step 26: Create AddCoffeeShopView
Create `Screens/New Coffee Shop/AddCoffeeShopView.swift` (see existing implementation)

**Target Membership:** iOS target only ✅

### Step 27: Create CoffeeShopDetailView
Create `Screens/Detail/CoffeeShopDetailView.swift` (see existing implementation)

**Target Membership:** iOS target only ✅

### Step 28: Create Watch CoffeeShopsListView
Create `Watch/Screens/CoffeeShopsListView.swift`:

```swift
import SwiftUI

struct CoffeeShopsListView: View {
    private let viewModel: CoffeeShopsMapViewModel
    private let container: DIContainer
    
    init(
        viewModel: CoffeeShopsMapViewModel,
        container: DIContainer
    ) {
        self.viewModel = viewModel
        self.container = container
    }
    
    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 5)) { context in
                List(viewModel.state.mapPlaces) { shop in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(shop.name)
                                .font(.headline)
                            Spacer()
                            Text("\(shop.rating)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(shop.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Coffee Shops")
        }
        .onAppear() {
            viewModel.fetchCoffeeShops()
        }
        .task {
            await startPeriodicViewUpdates()
        }
    }
    
    func startPeriodicViewUpdates() async {
        while true {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            viewModel.fetchCoffeeShops()
        }
    }
}
```

**Target Membership:** Watch target only ✅

### Step 29: Update App Entry Points

**iOS App (`CoffeeShopApp.swift`):**

```swift
import SwiftUI

@main
struct CoffeeShopApp: App {
    var body: some Scene {
        WindowGroup {
            CoffeeShopsMapView(
                viewModel: CoffeeShopsMapViewModel(
                    dataManager: DIContainer.shared.resolve(),
                    locationManager: DIContainer.shared.resolve()
                )
            )
            .environmentObject(DIContainer.shared)
        }
    }
}
```

**Watch App (`ContentView.swift`):**

```swift
import SwiftUI

struct ContentView: View {
    private let container = DIContainer.shared
    
    var body: some View {
        CoffeeShopsListView(
            viewModel: CoffeeShopsMapViewModel(
                dataManager: container.resolve() as DataManaging,
                locationManager: container.resolve() as LocationManaging
            ),
            container: container
        )
    }
}
```

---

## Phase 10: Testing

### Step 30: Add Accessibility Identifiers
Create `Utils/AccessibilityTag.swift` (see existing implementation)

**Target Membership:** iOS target only ✅

Add identifiers to views:
- Map view "Add Place" button
- Add form text fields and buttons
- Detail view components

### Step 31: Create Unit Tests
1. Create `CoffeeShopTests/Mocks/LocationManagerMock.swift`
2. Create `CoffeeShopTests/CoffeeShopsMapViewModelTests.swift` with 3 address test cases:
   - Valid address
   - Empty address
   - Whitespace-only address

### Step 32: Create UI Tests
1. Create `CoffeeShopUITests/CoffeeShopUITests.swift`
2. Test screen components exist
3. Test form validation
4. Test save button state

---

## Phase 11: Final Configuration

### Step 33: Target Membership Check
Verify all files are in correct targets:

**Both Targets:**
- Models (CoffeeShopPlace, CoffeeShopType)
- Protocols (DataManaging, LocationManaging)
- CoreDataManager
- DIContainer
- ViewModels (CoffeeShopsMapViewModel, State)

**iOS Only:**
- LocationManager (iOS version)
- WatchConnector
- All iOS Views
- UIComponents

**Watch Only:**
- LocationManager (watchOS version)
- PhoneConnector
- Watch Views

### Step 34: Build & Run
1. Build iOS app: Cmd + B
2. Build Watch app: Select Watch target → Cmd + B
3. Run on simulator or device
4. Test Watch connectivity with paired Watch

---

## Testing Checklist

- [ ] iOS app launches and shows map
- [ ] Location permission requested
- [ ] "Add Place" button opens form
- [ ] Form saves coffee shop to CoreData
- [ ] Coffee shop appears on map with pin
- [ ] Tapping pin shows detail view
- [ ] Detail view shows all information correctly
- [ ] Watch app receives new coffee shops
- [ ] Watch app displays list of coffee shops
- [ ] Unit tests pass (3 address test cases)
- [ ] UI tests pass (screen components exist)

---

## Common Issues & Solutions

**Issue:** CoreData not persisting
- **Solution:** Check target membership of `.xcdatamodeld`

**Issue:** Location not working
- **Solution:** Add location permission to Info.plist

**Issue:** Watch not receiving messages
- **Solution:** Ensure Watch app is running, session is activated, devices are paired

**Issue:** "Cannot find type" errors
- **Solution:** Check target membership of shared files

---

## Next Steps

- Add image support for coffee shops
- Implement search/filter functionality
- Add favorites feature
- Improve Watch UI design
- Add more comprehensive error handling

---

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [CoreData Guide](https://developer.apple.com/documentation/coredata)
- [WatchConnectivity Guide](https://developer.apple.com/documentation/watchconnectivity)
- [MapKit Documentation](https://developer.apple.com/documentation/mapkit)

---

**Good luck building your CoffeeShop app! ☕️**
