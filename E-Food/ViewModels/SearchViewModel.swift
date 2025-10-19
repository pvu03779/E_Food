//
//  Untitled.swift
//  E-Food
//
//  Created by Vu Phong on 18/10/25.
//
import CoreLocation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var recipeResults: [Recipe] = []
    @Published var locationString = "Checking location..."
    @Published var isLoading = false
    @Published var searchText = ""
    
    private let apiService = ApiService()
    private let geocoder = CLGeocoder()
    private var locationManager: LocationManager?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Debounce search text
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    self?.searchRecipes(query: query)
                } else {
                    self?.recipeResults = []
                }
            }
            .store(in: &cancellables)
    }

    // --- KEY CHANGE: Updated logic ---
    func setLocationManager(_ manager: LocationManager) {
        guard self.locationManager == nil else { return }
        self.locationManager = manager
        
        // 1. Check immediately if location already exists
        if let location = manager.location {
            self.geocodeLocation(location)
        } else {
            // 2. If not, subscribe to the *first* non-nil update
            manager.$location
                .compactMap { $0 }
                .first()
                .sink { [weak self] location in
                    self?.geocodeLocation(location)
                }
                .store(in: &cancellables)
        }
    }
    
    private func geocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                self?.locationString = "\(placemark.locality ?? "Unknown City"), \(placemark.country ?? "Unknown Country")"
            } else {
                self?.locationString = "Location not found"
            }
        }
    }
    
    func searchRecipes(query: String) {
        Task {
            isLoading = true
            do {
                recipeResults = try await apiService.fetchRecipes(query: query)
            } catch {
                print("Error searching recipes: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}
