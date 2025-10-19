//
//  E_FoodApp.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
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
