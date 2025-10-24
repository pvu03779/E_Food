//
//  RecipeDetailView.swift
//  E-Food
//

import SwiftUI
import Charts

struct RecipeDetailView: View {
    let recipeId: Int
    @StateObject var vm = RecipeDetailViewModel()
    @State var showVideo = false
    
    var body: some View {
        ScrollView {
            if vm.loading {
                ProgressView("Loading recipe info...")
                    .padding(.top, 50)
            } else if let recipe = vm.recipe {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // image / video section
                    ZStack {
                        AsyncImage(url: URL(string: recipe.image)) { img in
                            img.resizable()
                                .scaledToFit()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                                .frame(height: 250)
                        }
                        
                        if vm.video != nil {
                            Rectangle()
                                .fill(.black.opacity(0.4))
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                                .opacity(0.9)
                        }
                    }
                    .onTapGesture {
                        if vm.video != nil {
                            showVideo = true
                        }
                    }
                    
                    // recipe title
                    Text(recipe.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // meta info
                    HStack {
                        Label("\(recipe.readyInMinutes) mins", systemImage: "clock")
                        Spacer()
                        Label("\(recipe.servings) servings", systemImage: "person.fill")
                    }
                    .foregroundColor(.gray)
                    
                    Divider()
                    
                    // nutrition info (basic)
                    if let nutrients = recipe.nutrition?.nutrients {
                        Text("Nutrition Facts") // <-- Changed title to match design
                            .font(.title2)
                            .bold()
                        
                        // --- START: NEW CHART CODE ---
                        
                        // 1. Get the macros for the chart
                        let macros = nutrients.filter { ["Protein", "Fat", "Carbohydrates"].contains($0.name) }
                        
                        // 2. Get the calories for the center
                        let calories = nutrients.first { $0.name == "Calories" }
                        
                        ZStack {
                            Chart(macros) { nutrient in
                                SectorMark(
                                    angle: .value("Amount (g)", nutrient.amount),
                                    innerRadius: .ratio(0.7) // This makes it a donut
                                )
                                .foregroundStyle(by: .value("Nutrient", nutrient.name))
                            }
                            // 3. Add the legend at the bottom
                            .chartLegend(position: .bottom, alignment: .center)
                            
                            // 4. Add the Calories text in the middle
                            if let calories = calories {
                                VStack {
                                    Text("Calories")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.0f", calories.amount))
                                        .font(.title)
                                        .bold()
                                }
                            }
                        }
                        .frame(height: 220) // Give it a bit more space
                        
                        // --- END: NEW CHART CODE ---
                    }
                    
                    Divider()
                    
                    // ingredients
                    Text("Ingredients")
                        .font(.title2)
                        .bold()
                    ForEach(recipe.extendedIngredients) { ing in
                        Text("• \(ing.original)")
                    }
                    
                    Divider()
                    
                    // instructions
                    Text("Instructions")
                        .font(.title2)
                        .bold()
                    ForEach(recipe.analyzedInstructions) { inst in
                        ForEach(inst.steps) { step in
                            HStack(alignment: .top) {
                                Text("\(step.number).")
                                    .bold()
                                Text(step.step)
                            }
                        }
                    }
                    
                    // cooking now button
                    if let steps = recipe.analyzedInstructions.first?.steps {
                        NavigationLink(destination: CookingModeView(viewModel: CookingModeViewModel(steps: steps, title: recipe.title))) {
                            Text("Let's Cook!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
            } else if let error = vm.errorText {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Recipe Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: {
                vm.toggleFav()
            }) {
                Image(systemName: vm.fav ? "heart.fill" : "heart")
                    .foregroundColor(.orange)
            }
        }
        .sheet(isPresented: $showVideo) {
            if let video = vm.video {
                VideoPlayerView(youTubeId: video.youTubeId)
            }
        }
        .task {
            print("Fetching recipe \(recipeId)")
            await vm.loadRecipe(recipeId: recipeId)
        }
    }
}
