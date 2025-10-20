import Foundation
import CoreData

class PersistenceManager {
    static let shared = PersistenceManager()
    static let favoritesChangedNotification = Notification.Name("favoritesChanged")
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Favorite Operations
    
    /// Add a full recipe to favorites
    func addFavorite(recipe: RecipeDetail) {
        // Check if already exists
        if isFavorite(recipeId: recipe.id) {
            return
        }
        
        let favorite = FavoriteRecipe(context: context)
        favorite.recipeId = Int64(recipe.id)
        favorite.title = recipe.title
        favorite.imageURL = recipe.image
        favorite.readyInMinutes = Int32(recipe.readyInMinutes)
        favorite.dateAdded = Date()
        saveContext()
        
        // Post notification
        NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
    }
    
    /// Remove a recipe from favorites
    func removeFavorite(recipeId: Int) {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let results = try context.fetch(fetchRequest)
            for favorite in results {
                context.delete(favorite)
            }
            saveContext()
            
            // Post notification
            NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
        } catch {
            print("Error removing favorite: \(error)")
        }
    }
    
    /// Check if a recipe is favorited
    func isFavorite(recipeId: Int) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking favorite: \(error)")
            return false
        }
    }
    
    /// Get all favorite recipe objects (sorted by date added, newest first)
    func fetchAllFavorites() throws -> [FavoriteRecipe] {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
    
    /// Clear all favorites
    func clearAllFavorites() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteRecipe.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
            
            // Post notification
            NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
        } catch {
            print("Error clearing favorites: \(error)")
        }
    }
}
