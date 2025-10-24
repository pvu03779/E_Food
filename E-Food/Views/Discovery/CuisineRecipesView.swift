//
//  CuisineRecipesView.swift
//  E-Food
//

import SwiftUI

struct CuisineRecipesView: View {
    
    var cuisine: String
    @StateObject var viewModel = CuisineViewModel()
    
    var body: some View {
        VStack {
            if viewModel.loading {
                ProgressView("Loading...")
            } else if let msg = viewModel.errorText {
                Text(msg)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(viewModel.recipes, id: \.id) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipeId: recipe.id)
                    } label: {
                        RecipeRowView(recipe: recipe)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("\(cuisine) Recipes")
        .onAppear {
            print("Fetching recipes for \(cuisine)")
            Task {
                await viewModel.loadRecipes(cuisine: cuisine)
            }
        }
    }
}
