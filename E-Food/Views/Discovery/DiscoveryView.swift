//
//  DiscoveryView.swift
//  E-Food
//

import SwiftUI

struct DiscoveryView: View {
    @StateObject var viewModel = DiscoveryViewModel()

    let cuisines: [(name: String, icon: String)] = [
        ("American", "american_icon"),
        ("Italian", "italian_icon"),
        ("Korean", "korean_icon"),
        ("Mexican", "mexican_icon"),
        ("Indian", "indian_icon"),
        ("Thai", "thai_icon"),
        ("Mediterranean", "mediterranean_icon"),
        ("French", "french_icon")
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    HStack(spacing: 0) {
                        Text("What's ")
                        Text("Cooking").foregroundColor(.orange)
                        Text(" Today?")
                    }
                    .font(.title)
                    .fontWeight(.bold)
                    
                    NavigationLink(destination: SearchView(isPushedView: true)) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text("Search for recipes, ingredients...")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(cuisines, id: \.name) { cuisine in
                            NavigationLink(destination: CuisineRecipesView(cuisine: cuisine.name)) {
                                VStack {
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
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Trending Recipes")
                                .font(.title2)
                                .bold()
                            Spacer()
                            NavigationLink("See all", destination: TrendingRecipesView(recipes: viewModel.recipes))
                                .foregroundColor(.orange)
                        }
                        
                        if viewModel.loading {
                            ProgressView("Loading...")
                                .frame(height: 200)
                                .padding(.top, 20)
                        } else if let error = viewModel.errorText {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.recipes) { recipe in
                                        NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                                            RecipeCardView(recipe: recipe)
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .task {

            if viewModel.recipes.isEmpty {
                await viewModel.getTrending()
            }
        }
    }
}

struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView()
    }
}
