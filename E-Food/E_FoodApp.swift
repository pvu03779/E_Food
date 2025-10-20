//
//  E_FoodApp.swift
//  E-Food
//

import SwiftUI

@main
struct E_FoodApp: App {
    @StateObject private var locationManager = LocationManager()
    
    init() {
        // Request notification permissions on app launch
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}
