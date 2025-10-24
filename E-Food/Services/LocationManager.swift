//
//  LocationManager.swift
//  E-Food
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var status: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // ask user for location stuff
        askForPermission()
    }
    
    func askForPermission() {
        let auth = locationManager.authorizationStatus
        
        // if user never said yes or no yet
        if auth == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if auth == .authorizedWhenInUse || auth == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location not allowed by user")
        }
    }
    
    // called when permission changes (I think)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.status = manager.authorizationStatus
            
            if self.status == .authorizedWhenInUse || self.status == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
            } else {
                self.locationManager.stopUpdatingLocation()
                self.currentLocation = nil
            }
        }
    }
    
    // gets called when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first {
            DispatchQueue.main.async {
                self.currentLocation = first
                print("Got location: \(first.coordinate.latitude), \(first.coordinate.longitude)")
                
                // probably don’t need to keep tracking?
                self.locationManager.stopUpdatingLocation()
            }
        } else {
            print("No location found")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location failed: \(error.localizedDescription)")
    }
}
