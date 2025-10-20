//
//  DiscoveryViewModel.swift
//  E-Food
//

import Foundation

@MainActor
class DiscoveryViewModel: ObservableObject {
    @Published var trendingRecipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = ApiService()

    func fetchTrendingRecipes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            trendingRecipes = try await service.fetchRecipes()
        } catch {
            errorMessage = "Failed to fetch recipes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
