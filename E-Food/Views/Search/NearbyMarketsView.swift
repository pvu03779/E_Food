//
//  NearbyMarketsView.swift
//  E-Food
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct NearbyMarketsView: View {
    @StateObject var viewModel = MarketsViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            VStack {
                
                // show message if location not allowed
                locationStatusView
                
                // map area
                Map(position: $viewModel.mapPosition) {
                    ForEach(viewModel.markets) { market in
                        Annotation(market.item.name ?? "Supermarket",
                                   coordinate: market.item.placemark.coordinate) {
                            Image(systemName: "cart.circle.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                    
                    
                    // show user location pin
                    if let myLocation = viewModel.locationManager?.currentLocation {
                        Annotation("Me", coordinate: myLocation.coordinate) {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .frame(height: 300)
                .padding(.bottom, 5)
                
                // list area or loading
                if viewModel.isLoading {
                    ProgressView("Finding nearby markets...")
                        .padding()
                    Spacer()
                } else if viewModel.markets.isEmpty {
                    Text("No markets found nearby 😕")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List(viewModel.markets) { market in
                        MarketRowView(market: market)
                            .onTapGesture {
                                viewModel.selectMarket(market)
                            }
                    }
                    .listStyle(.plain)
                    .environmentObject(viewModel)
                }
            }
            .navigationTitle("Nearby Markets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // make sure to set up location manager
                viewModel.setupLocationManager(locationManager)
            }
        }
    }
    
    // MARK: - Location Permission View
    @ViewBuilder
    private var locationStatusView: some View {
        if let status = viewModel.locationManager?.status {
            if status == .denied || status == .restricted {
                VStack(spacing: 6) {
                    Text("Location Access Denied")
                        .font(.headline)
                    Text("Please allow location access in Settings.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - View Model
@MainActor
class MarketsViewModel: ObservableObject {
    @Published var markets: [MarketItem] = []
    @Published var isLoading = false
    @Published var mapPosition: MapCameraPosition = .automatic
    @Published var selectedMarket: MarketItem?
    
    var locationManager: LocationManager?
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    func setupLocationManager(_ manager: LocationManager) {
        if locationManager == nil {
            locationManager = manager
        }
        
        // if we already have location, start searching
        if let loc = manager.currentLocation {
            searchNearby(location: loc)
        } else {
            // wait for location to show up
            manager.$currentLocation
                .compactMap { $0 }
                .first()
                .sink { [weak self] location in
                    self?.searchNearby(location: location)
                }
                .store(in: &cancellables)
        }
    }
    
    func searchNearby(location: CLLocation) {
        isLoading = true
        searchTask?.cancel()
        
        searchTask = Task {
            defer { isLoading = false }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "supermarket"
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
            
            do {
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                
                var tempMarkets: [MarketItem] = []
                for item in response.mapItems {
                    if let loc = item.placemark.location {
                        let dist = location.distance(from: loc)
                        tempMarkets.append(MarketItem(item: item, distance: dist))
                    }
                }
                
                tempMarkets.sort { ($0.distance ?? 0) < ($1.distance ?? 0) }
                self.markets = tempMarkets
                updateMap(location: location)
            } catch {
                print("Error while searching: \(error)")
                self.markets = []
            }
        }
    }
    
    func selectMarket(_ market: MarketItem) {
        selectedMarket = market
        mapPosition = .region(MKCoordinateRegion(
            center: market.item.placemark.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        ))
        getETA(for: market)
    }
    
    func updateMap(location: CLLocation) {
        mapPosition = .region(MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        ))
    }
    
    func getETA(for market: MarketItem) {
        guard let userLoc = locationManager?.currentLocation else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLoc.coordinate))
        request.destination = market.item
        request.transportType = .automobile
        
        Task {
            do {
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    if let index = markets.firstIndex(where: { $0.id == market.id }) {
                        markets[index].eta = route.expectedTravelTime
                    }
                }
            } catch {
                print("Failed to get ETA: \(error)")
            }
        }
    }
    
    func openInMaps(_ item: MKMapItem) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        item.openInMaps(launchOptions: options)
    }
}

// MARK: - Model
struct MarketItem: Identifiable {
    let id = UUID()
    let item: MKMapItem
    let distance: CLLocationDistance?
    var eta: TimeInterval?
    
    var distanceText: String? {
        guard let distance else { return nil }
        let f = LengthFormatter()
        f.unitStyle = .short
        return f.string(fromMeters: distance)
    }
    
    var etaText: String? {
        guard let eta else { return nil }
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .short
        return f.string(from: eta)
    }
}

// MARK: - Row
struct MarketRowView: View {
    let market: MarketItem
    @EnvironmentObject var viewModel: MarketsViewModel
    
    var body: some View {
        Button {
            viewModel.openInMaps(market.item)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(market.item.name ?? "Unknown Market")
                        .font(.headline)
                    Text(market.item.placemark.title ?? "No address available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let dist = market.distanceText {
                        Text(dist)
                            .font(.subheadline)
                    }
                    if let eta = market.etaText {
                        Text("~\(eta) drive")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
