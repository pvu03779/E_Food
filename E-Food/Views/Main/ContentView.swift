//
//  ContentView.swift
//  E-Food
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiscoveryView()
                .tabItem {
                    Label("Discover", systemImage: "house")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
