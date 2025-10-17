//
//  E_FoodApp.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

import SwiftUI

@main
struct E_FoodApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
