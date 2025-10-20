//
//  NearbyMarketsView.swift
//  E-Food
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: - Main Markets View
struct NearbyMarketsView: View {
    @StateObject private var viewModel = MarketsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. Location Status / Permission Prompt
                locationStatusView
                
                // 2. Map View
                Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedResult) {
                    ForEach(viewModel.searchResults) { result in
                        Annotation(
                            result.item.name ?? "Supermarket",
                            coordinate: result.item.placemark.coordinate
                        ) {
                            Image(systemName: "cart.circle.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                                .background(.white)
                                .clipShape(Circle())
                        }
                    }
                    
                    if let userLocation = viewModel.locationManager?.location {
                        Annotation("My Location", coordinate: userLocation.coordinate) {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                                .background(.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .frame(height: 300)
                
                // 3. Results List
                if viewModel.isSearching {
                    ProgressView("Searching for nearby markets...")
                        .padding()
                    Spacer()
                } else if viewModel.searchResults.isEmpty {
                    Text("No nearby markets found. We search for 'supermarket' and 'grocery'.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List(viewModel.searchResults) { result in
                        SupermarketRowView(result: result)
                            .onTapGesture {
                                // This selects the item on the map
                                viewModel.selectResult(result)
                            }
                    }
                    .listStyle(PlainListStyle())
                    .environmentObject(viewModel)
                }
            }
            .navigationTitle("Nearby Markets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.setLocationManager(locationManager)
            }
        }
    }
    
    /// A helper view to show the user the status of their location permission.
    @ViewBuilder
    private var locationStatusView: some View {
        switch viewModel.locationManager?.authorizationStatus {
        case .denied, .restricted:
            VStack {
                Text("Location Access Denied")
                    .font(.headline)
                Text("Enable location access in Settings to find supermarkets near you.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
        case .notDetermined, .authorizedWhenInUse, .authorizedAlways, .none:
            EmptyView()
        default:
            EmptyView()
        }
    }
}

// MARK: - View Model
@MainActor
class MarketsViewModel: ObservableObject {
    @Published var searchResults: [SupermarketResult] = []
    
    @Published var isSearching = false
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var selectedResult: SupermarketResult?
    
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var locationManager: LocationManager?
    
    init() {
        // Init is now empty
    }
    
    func setLocationManager(_ manager: LocationManager) {
        guard self.locationManager == nil else { return }
        self.locationManager = manager
        
        if let location = manager.location {
            self.performSearch(location: location)
        } else {
            manager.$location
                .compactMap { $0 }
                .first()
                .sink { [weak self] location in
                    self?.performSearch(location: location)
                }
                .store(in: &cancellables)
        }
    }
    
    func selectResult(_ result: SupermarketResult) {
        self.selectedResult = result
        self.cameraPosition = .region(MKCoordinateRegion(
            center: result.item.placemark.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        ))
        fetchETA(for: result)
    }
    
    func performSearch(location: CLLocation) {
        searchTask?.cancel()
        searchTask = Task {
            isSearching = true
            defer { isSearching = false }
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "mart"
            request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            
            do {
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                
                if !Task.isCancelled {
                    // Map the results
                    var results = response.mapItems.compactMap { item -> SupermarketResult? in
                        guard let itemLocation = item.placemark.location else {
                            return nil
                        }
                        let distance = location.distance(from: itemLocation)
                        return SupermarketResult(item: item, distance: distance)
                    }
                    results.sort { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
                    
                    self.searchResults = results
                    updateMapRegion(location: location)
                }
            } catch {
                if !Task.isCancelled {
                    print("Search error: \(error.localizedDescription)")
                    self.searchResults = []
                }
            }
        }
    }
    
    private func updateMapRegion(location: CLLocation) {
        cameraPosition = .region(MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        ))
    }
    
    func fetchETA(for result: SupermarketResult) {
        guard let userLocation = locationManager?.location else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = result.item
        request.transportType = .automobile
        
        Task {
            do {
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    if let index = searchResults.firstIndex(where: { $0.id == result.id }) {
                        searchResults[index].eta = route.expectedTravelTime
                    }
                }
            } catch {
                print("Failed to fetch ETA: \(error)")
            }
        }
    }
    
    /// Opens the selected map item in Apple Maps for navigation.
    func openInMaps(_ mapItem: MKMapItem) {
        // Set launch options to show driving directions
        // from the user's current location.
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}

// MARK: - Model
struct SupermarketResult: Identifiable, Hashable {
    let id = UUID()
    let item: MKMapItem
    let distance: CLLocationDistance?
    var eta: TimeInterval?
    
    static func == (lhs: SupermarketResult, rhs: SupermarketResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var distanceString: String? {
        guard let distance else { return nil }
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        return formatter.string(fromMeters: distance)
    }
    
    var etaString: String? {
        guard let eta else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: eta)
    }
}

// MARK: - Helper Views
struct SupermarketRowView: View {
    let result: SupermarketResult
    @EnvironmentObject private var viewModel: MarketsViewModel
    
    var body: some View {
        Button(action: {
            viewModel.openInMaps(result.item)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.item.name ?? "Unknown")
                        .font(.headline)
                    Text(result.item.placemark.title ?? "No address")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let distance = result.distanceString {
                        Text(distance)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    if let eta = result.etaString {
                        Text("~ \(eta) drive")
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
