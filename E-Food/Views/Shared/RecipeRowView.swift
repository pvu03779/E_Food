//
//  RecipeRowView.swift
//  E-Food
//

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: recipe.image)) { image in
                image.resizable()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 100, height: 100)
            .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(recipe.title).font(.headline).lineLimit(2)
                Text("\(recipe.readyInMinutes ?? 45) Min | \(recipe.difficulty)")
                    .font(.subheadline).foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}
