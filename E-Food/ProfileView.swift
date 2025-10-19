//
//  ProfileView.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Form {
                // User Profile Section
                Section {
                    HStack {
                        Image("profile_avatar") // Replace with your avatar image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        Text("James Barron")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical)
                }

                // Menu Options Section
                Section {
                    NavigationLink(destination: Text("Manage Subscription")) {
                        Text("Manage Subscription")
                    }
                    NavigationLink(destination: Text("Settings")) {
                        Text("Settings")
                    }
                    NavigationLink(destination: Text("Help Centre")) {
                        Text("Help Centre")
                    }
                    NavigationLink(destination: Text("Share Feedback")) {
                        Text("Share Feedback")
                    }
                    NavigationLink(destination: Text("About Chefly")) {
                        Text("About Chefly")
                    }
                    NavigationLink(destination: Text("Terms and Conditions")) {
                        Text("Terms and Conditions")
                    }
                    NavigationLink(destination: Text("Rate Chefly")) {
                        Text("Rate Chefly")
                    }
                }

                // Sign Out Section
                Section {
                    Button(action: {
                        // Handle sign out action
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
