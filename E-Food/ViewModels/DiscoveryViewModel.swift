//
//  DiscoveryViewModel.swift
//  E-Food
//

import Foundation

@MainActor
class DiscoveryViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var loading = false
    @Published var errorText: String? = nil
    
    let api = ApiService()
    
    // get some trending recipes
    func getTrending() async {
        loading = true
        errorText = nil
        print("Loading trending recipes...")
        
        do {
            let fetched = try await api.searchRecipes()
            self.recipes = fetched
            print("Got \(fetched.count) recipes!")
        } catch {
            print("Error:", error)
            self.errorText = "Couldn’t get trending recipes"
        }
        
        loading = false
    }
}
