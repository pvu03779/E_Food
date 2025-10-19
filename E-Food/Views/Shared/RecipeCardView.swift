//
//  RecipeCard.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

import SwiftUICore
import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // AsyncImage loads the image from the URL
            AsyncImage(url: URL(string: recipe.image)) { image in
                image.resizable()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 250)
            .cornerRadius(15)

            // Fading overlay for text visibility
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 120)
            }
            .cornerRadius(15)
            
            // Rating overlay
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", (Double(recipe.healthScore ?? 80) / 20.0))) // Example rating
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .padding(8)
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .padding([.top, .trailing], 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)


            // Recipe details text
            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(recipe.readyInMinutes ?? 45) Min | \(recipe.difficulty)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .frame(width: 200, height: 250)
    }
}
