//
//  SearchView.swift
//  E-Food
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    @State private var showMap = false
    @EnvironmentObject var locationManager: LocationManager
    
    var isPushedView: Bool = false
    
    var searchViewContent: some View {
            VStack {
                SearchBarView(text: $viewModel.searchText)
                    .padding(.top, 10)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                    Text(viewModel.locationText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .onTapGesture {
                    showMap.toggle()
                }
                
                Divider()
                
                // Recipe List or Loading
                if viewModel.isLoading && viewModel.recipeResults.isEmpty {
                    VStack {
                        ProgressView("Searching recipes...")
                            .padding()
                        Spacer()
                    }
                } else if viewModel.recipeResults.isEmpty {
                    if !viewModel.searchText.isEmpty {
                        Text("No results for '\(viewModel.searchText)'")
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    } else {
                        Text("Start typing to find recipes")
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.recipeResults) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                                RecipeRowView(recipe: recipe)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Find Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showMap) {
                NearbyMarketsView()
                    .environmentObject(locationManager)
            }
            .onAppear {
                viewModel.setLocationManager(locationManager)
            }
        }
    
    var body: some View {
            if isPushedView {
                searchViewContent
            } else {
                NavigationView {
                    searchViewContent
                }
            }
        }
    
}

// MARK: - Search Bar View
struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Type recipe name...", text: $text)
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.trailing, 4)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
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
