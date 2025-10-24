//
//  PersistenceManager.swift
//  E-Food
//

import Foundation
import CoreData

class PersistenceManager {
    static let shared = PersistenceManager()
    
    // notification name for favorites update
    static let favsChanged = Notification.Name("favsChanged")
    
    // making sure it's a singleton
    private init() {}
    
    // MARK: - Core Data setup
    lazy var container: NSPersistentContainer = {
        let c = NSPersistentContainer(name: "DataModel")
        c.loadPersistentStores { desc, error in
            if let error = error {
                print("can't load core data: \(error)")
            } else {
                print("CoreData ready to go!")
            }
        }
        return c
    }()
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    // MARK: - Save
    func saveStuff() {
        if context.hasChanges {
            do {
                try context.save()
                print("Saved to CoreData!")
            } catch {
                print("Couldn't save: \(error)")
            }
        }
    }
    
    // MARK: - Favorite Stuff
    
    // adds a recipe to favorites
    func addToFavs(recipe: RecipeDetail) {
        // check if already there
        if alreadyFav(recipeId: recipe.id) {
            print("Already in favs!")
            return
        }
        
        let fav = FavoriteRecipe(context: context)
        fav.recipeId = Int64(recipe.id)
        fav.title = recipe.title
        fav.imageURL = recipe.image
        fav.readyInMinutes = Int32(recipe.readyInMinutes)
        fav.dateAdded = Date()
        
        saveStuff()
        
        NotificationCenter.default.post(name: Self.favsChanged, object: nil)
    }
    
    // removes from favorites
    func removeFromFavs(recipeId: Int) {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let list = try context.fetch(request)
            for f in list {
                context.delete(f)
            }
            saveStuff()
            NotificationCenter.default.post(name: Self.favsChanged, object: nil)
        } catch {
            print("Can't remove favorite: \(error)")
        }
    }
    
    // check if it's already a favorite
    func alreadyFav(recipeId: Int) -> Bool {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error checking fav: \(error)")
            return false
        }
    }
    
    // get all favs
    func getAllFavs() -> [FavoriteRecipe] {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        do {
            let list = try context.fetch(request)
            print("Fetched \(list.count) favorites")
            return list
        } catch {
            print("Can't fetch favorites: \(error)")
            return []
        }
    }
    
    // delete everything
    func deleteAllFavs() {
        let fetch: NSFetchRequest<NSFetchRequestResult> = FavoriteRecipe.fetchRequest()
        let deleteReq = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try context.execute(deleteReq)
            saveStuff()
            NotificationCenter.default.post(name: Self.favsChanged, object: nil)
        } catch {
            print("Can't delete all favs: \(error)")
        }
    }
}
