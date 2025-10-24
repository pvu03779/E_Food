//
//  FavoritesView.swift
//  E-Food
//

import SwiftUI

struct FavoritesView: View {
    @StateObject var vm = FavoritesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if vm.loading {
                    ProgressView("Loading... please wait")
                } else if let err = vm.errorText {
                    Text(err)
                        .foregroundColor(.red)
                        .padding()
                } else if vm.favs.isEmpty {
                    Text("No favorite recipes yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(vm.favs) { fav in
                            NavigationLink(destination: RecipeDetailView(recipeId: Int(fav.recipeId))) {
                                FavRow(recipe: fav)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                print("View appeared, loading favorites...")
                vm.loadFavs()
            }
        }
    }
}

struct FavRow: View {
    let recipe: FavoriteRecipe
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: recipe.imageURL ?? "")) { img in
                img.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 70, height: 70)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(recipe.title ?? "Untitled")
                    .font(.headline)
                Text("\(recipe.readyInMinutes) mins")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(5)
    }
}
