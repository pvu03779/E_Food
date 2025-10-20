//
//  TrendingRecipesView.swift
//  E-Food
//

import SwiftUICore
import SwiftUI

struct TrendingRecipesView: View {
    let recipes: [Recipe]

    var body: some View {
        List(recipes) { recipe in
            NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                RecipeRowView(recipe: recipe)
            }
        }
        .navigationTitle("Trending Recipes")
        .listStyle(PlainListStyle())
    }
}
