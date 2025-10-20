//
//  CuisineViewModel.swift
//  E-Food
//

import Foundation

@MainActor
class CuisineViewModel: ObservableObject {
    @Published var cuisineRecipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = ApiService()

    func fetchRecipes(for cuisine: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            cuisineRecipes = try await service.fetchRecipes(query: nil, cuisine: cuisine)
        } catch {
            errorMessage = "Failed to fetch recipes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
