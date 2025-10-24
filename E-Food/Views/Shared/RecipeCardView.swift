//
//  RecipeCardView.swift
//  E-Food
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // show image from URL (AsyncImage loads it)
            AsyncImage(url: URL(string: recipe.image)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                // if image not loaded yet
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 200, height: 250)
            .cornerRadius(15)
            .clipped()
            
            // make bottom darker so text can be seen
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(15)
            .frame(height: 120)
            .frame(maxHeight: .infinity, alignment: .bottom)
            
            // add rating (just a star + number)
            VStack {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", (Double(recipe.healthScore ?? 80) / 20.0)))
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding(6)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(10)
                
                Spacer()
            }
            
            // bottom text info
            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(.bottom, 2)
                
                Text("\(recipe.readyInMinutes ?? 45) mins | \(recipe.difficulty)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
        .frame(width: 200, height: 250)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}
