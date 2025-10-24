//
//  RecipeRowView.swift
//  E-Food
//

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            
            // load recipe image from the internet
            AsyncImage(url: URL(string: recipe.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                // show gray box while image loads
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)
            .clipped()
            
            // recipe info
            VStack(alignment: .leading, spacing: 4) {
                // recipe name
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                
                // small text below
                Text("\(recipe.readyInMinutes ?? 45) mins | \(recipe.difficulty)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
