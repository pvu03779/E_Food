//
//  FavoritesViewModel.swift
//  E-Food
//

import Foundation
import Combine
import CoreData

@MainActor
class FavoritesViewModel: ObservableObject {
    
    @Published var favs: [FavoriteRecipe] = []
    @Published var loading = false
    @Published var errorText: String? = nil
    
    let core = PersistenceManager.shared
    var subs = Set<AnyCancellable>()
    
    init() {
        // listen for changes from other screens
        NotificationCenter.default.publisher(for: PersistenceManager.favsChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Favorites changed")
                self?.loadFavs()
            }
            .store(in: &subs)
    }
    
    func loadFavs() {
        loading = true
        errorText = nil
        print("Fetching favorite recipes")
        
        do {
            favs = try core.getAllFavs()
            print("Got \(favs.count) favorites")
        } catch {
            print("Error getting favorites:", error)
            errorText = "Couldn't load favorites"
        }
        
        loading = false
    }
}
