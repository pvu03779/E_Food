//
//  SearchViewModel.swift
//  E-Food
//

import CoreLocation
import Combine

class SearchViewModel: ObservableObject {
    @Published var recipeResults: [Recipe] = []
    @Published var locationText = "Getting your location..."
    @Published var isLoading = false
    @Published var searchText = ""
    
    private var api = ApiService()
    private var geocoder = CLGeocoder()
    private var locationManager: LocationManager?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen to search text changes
        $searchText
            .debounce(for: .milliseconds(600), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.recipeResults = []
                } else {
                    self.searchForRecipes(with: text)
                }
            }
            .store(in: &cancellables)
    }
    
    func setLocationManager(_ manager: LocationManager) {
        if locationManager != nil {
            return
        }
        
        locationManager = manager
        
        if let loc = manager.currentLocation {
            convertLocationToText(loc)
        } else {
            // wait for the first location update
            manager.$currentLocation
                .compactMap { $0 }
                .first()
                .sink { [weak self] loc in
                    self?.convertLocationToText(loc)
                }
                .store(in: &cancellables)
        }
    }
    
    private func convertLocationToText(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let err = error {
                print("Geocode error: \(err.localizedDescription)")
                self.locationText = "Couldn’t find location"
                return
            }
            
            if let place = placemarks?.first {
                let city = place.locality ?? "Unknown"
                let country = place.country ?? ""
                self.locationText = "\(city), \(country)"
            } else {
                self.locationText = "No location info"
            }
        }
    }
    
    func searchForRecipes(with name: String) {
        Task {
            isLoading = true
            
            do {
                let results = try await api.searchRecipes(name: name)
                DispatchQueue.main.async {
                    self.recipeResults = results
                }
            } catch {
                print("Search failed: \(error)")
            }
            
            isLoading = false
        }
    }
}
