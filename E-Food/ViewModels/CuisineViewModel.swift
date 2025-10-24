//
//  CuisineViewModel.swift
//  E-Food
//

import Foundation

@MainActor
class CuisineViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var loading = false
    @Published var errorText: String? = nil
    
    let api = ApiService()
    
    // tries to get recipes for a cuisine
    func loadRecipes(cuisine: String) async {
        loading = true
        errorText = nil
        print("load recipes for \(cuisine)...")
        
        do {
            let result = try await api.searchRecipes(cuisine: cuisine)
            self.recipes = result
            print("Get \(result.count) recipes")
        } catch {
            print("Error:", error)
            self.errorText = "Could not load recipes"
        }
        
        loading = false
    }
}
