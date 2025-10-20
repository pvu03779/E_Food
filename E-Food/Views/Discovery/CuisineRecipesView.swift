//
//  CuisineRecipesView.swift
//  E-Food
//

import SwiftUICore
import SwiftUI

struct CuisineRecipesView: View {
    let cuisine: String
    @StateObject private var viewModel = CuisineViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red).padding()
            } else {
                List(viewModel.cuisineRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                        RecipeRowView(recipe: recipe)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle(cuisine)
        .task {
            await viewModel.fetchRecipes(for: cuisine)
        }
    }
}
