//
//  DiscoveryView.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

import SwiftUI

struct DiscoveryView: View {
    @StateObject private var viewModel = DiscoveryViewModel()
    
    // Data for the cuisine categories grid
    private let cuisines: [(name: String, icon: String)] = [
        ("American", "american_icon"),
        ("Italian", "italian_icon"),
        ("Korean", "korean_icon"),
        ("Mexican", "mexican_icon"),
        ("Indian", "indian_icon"),
        ("Thai", "thai_icon"),
        ("Mediterranean", "mediterranean_icon"),
        ("French", "french_icon")
    ]
    
    // Grid layout configuration
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerTitle
                    searchBar
                    cuisineGrid
                    trendingSection
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .task {
            if viewModel.trendingRecipes.isEmpty {
                await viewModel.fetchTrendingRecipes()
            }
        }
    }
    
    // MARK: - View Components
    private var headerTitle: some View {
        HStack(spacing: 0) {
            Text("What's ")
            Text("Cooking").foregroundColor(.orange)
            Text(" Today?")
        }
        .font(.title)
        .fontWeight(.bold)
    }
    
    private var searchBar: some View {
        // Navigates to the SearchView when tapped
        NavigationLink(destination: SearchView()) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                Text("Search by ingredient, cuisine, or dish...")
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle()) // Ensures the entire area is tappable
    }
    
    private var cuisineGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(cuisines, id: \.name) { cuisine in
                NavigationLink(destination: CuisineRecipesView(cuisine: cuisine.name)) {
                    VStack {
                        // This now uses the image name from your assets
                        Image(cuisine.icon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        Text(cuisine.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var trendingSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Trending Recipes").font(.title2).fontWeight(.bold)
                Spacer()
                NavigationLink("See all", destination: TrendingRecipesView(recipes: viewModel.trendingRecipes))
                    .foregroundColor(.orange)
            }
            if viewModel.isLoading {
                ProgressView().frame(height: 250)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red).padding().frame(height: 250)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.trendingRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) { // Pass recipeId
                                RecipeCardView(recipe: recipe)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
}

struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView()
    }
}
