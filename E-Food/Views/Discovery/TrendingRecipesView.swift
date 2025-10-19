//
//  TrendingRecipesView.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

import SwiftUICore
import SwiftUI

struct TrendingRecipesView: View {
    let recipes: [Recipe]

    var body: some View {
        List(recipes) { recipe in
            NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) { // Pass recipeId
                RecipeRowView(recipe: recipe)
            }
        }
        .navigationTitle("Trending Recipes")
        .listStyle(PlainListStyle())
    }
}
