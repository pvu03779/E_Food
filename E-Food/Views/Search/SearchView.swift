//
//  SearchView.swift
//  E-Food
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isShowingMapView = false
    
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. Search Bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.top)

                // 2. Location Label
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.orange)
                    Text(viewModel.locationString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .onTapGesture {
                    isShowingMapView = true
                }
                
                // 3. Results List
                if viewModel.isLoading {
                    ProgressView("Finding recipes...")
                        .padding()
                    Spacer()
                } else if viewModel.recipeResults.isEmpty && !viewModel.searchText.isEmpty {
                    Text("No recipes found for \"\(viewModel.searchText)\"")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List(viewModel.recipeResults) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                            // Use the existing RecipeRowView
                            RecipeRowView(recipe: recipe)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Search Recipes")
            .sheet(isPresented: $isShowingMapView) {
                NearbyMarketsView()
                    .environmentObject(locationManager)
            }
            .onAppear {
                viewModel.setLocationManager(locationManager)
            }
        }
    }
}

// MARK: - Helper Views
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search for any recipe...", text: $text)
                .padding(10)
                .background(Color(.systemGray5))
                .cornerRadius(8)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(LocationManager())
    }
}
