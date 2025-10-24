//
//  RecipeDetailViewModel.swift
//  E-Food
//

import Foundation

@MainActor
class RecipeDetailViewModel: ObservableObject {
    
    @Published var recipe: RecipeDetail? = nil
    @Published var video: VideoInfo? = nil
    @Published var loading = false
    @Published var errorText: String? = nil
    @Published var fav = false
    
    let api = ApiService()
    let db = PersistenceManager.shared
    
    func loadRecipe(recipeId: Int) async {
        loading = true
        errorText = nil
        print("Loading recipe detail for id \(recipeId)")
        
        // just in case we already loaded this recipe
        if recipe?.id == recipeId {
            print("Already loaded, skipping fetch.")
            loading = false
            return
        }
        
        do {
            // get recipe info
            let detail = try await api.getRecipeDetails(id: recipeId)
            self.recipe = detail
            print("Got recipe detail: \(detail.title)")
            
            // try get video
            self.video = try await api.getVideo(query: detail.title)
            print("Fetched video for \(detail.title)")
            
            // check favorite
            self.fav = db.alreadyFav(recipeId: recipeId)
            
        } catch {
            print("Something went wrong: \(error)")
            errorText = "Couldn't load recipe info"
        }
        
        loading = false
    }
    
    func toggleFav() {
        guard let recipe = recipe else {
            print("No recipe to favorite!")
            return
        }
        
        if fav {
            db.removeFromFavs(recipeId: recipe.id)
            print("Removed from favorites")
        } else {
            db.addToFavs(recipe: recipe)
            print("Added to favorites")
        }
        
        fav.toggle()
    }
}
