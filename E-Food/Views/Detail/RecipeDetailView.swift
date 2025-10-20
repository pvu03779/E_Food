//
//  RecipeDetailView.swift
//  E-Food
//

import SwiftUI
import Charts

struct RecipeDetailView: View {
    let recipeId: Int
    @StateObject private var viewModel = RecipeDetailViewModel()
    @State private var isShowingVideo = false
    
    private var primaryNutrients: [Nutrient] {
        let nutrientNames = ["Calories", "Protein", "Fat", "Carbohydrates"]
        return viewModel.recipeDetail?.nutrition?.nutrients.filter {
            nutrientNames.contains($0.name)
        } ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView("Loading Recipe...")
                        .frame(height: 300)
                } else if let detail = viewModel.recipeDetail {
                    HeaderMediaView(videoInfo: viewModel.videoInfo, imageUrl: detail.image)
                        .onTapGesture {
                            if viewModel.videoInfo != nil {
                                isShowingVideo = true
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(detail.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Metadata
                        HStack {
                            Label("\(detail.readyInMinutes) min", systemImage: "clock")
                            Spacer()
                            Label("\(detail.servings) servings", systemImage: "person.2")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        if !primaryNutrients.isEmpty {
                            Divider()
                            Text("Nutrition Facts").font(.title2).fontWeight(.semibold)
                            // A vertical bar chart with colored bars and no grid lines.
                            Chart(primaryNutrients) { nutrient in
                                BarMark(
                                    x: .value("Nutrient", nutrient.name),
                                    y: .value("Amount", nutrient.amount)
                                )
                                .foregroundStyle(by: .value("Nutrient", nutrient.name))
                                .annotation(position: .top, alignment: .center) {
                                    Text(String(format: "%.0f", nutrient.amount))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .chartYAxis(.hidden) // Hide Y-axis grid lines and labels
                            .chartXAxis { // Customize X-axis to only show labels
                                AxisMarks { _ in
                                    AxisValueLabel()
                                }
                            }
                            .chartLegend(.hidden)
                            .frame(height: 200)
                        }
                        Divider()
                        
                        // Ingredients Section
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)
                        ForEach(detail.extendedIngredients) { ingredient in
                            Text("• \(ingredient.original)")
                        }
                        
                        Divider()
                        
                        // Instructions Section
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        ForEach(detail.analyzedInstructions) { instructionSet in
                            ForEach(instructionSet.steps) { step in
                                HStack(alignment: .top) {
                                    Text("\(step.number).")
                                        .fontWeight(.bold)
                                        .padding(.trailing, 4)
                                    Text(step.step)
                                }
                                .padding(.bottom, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .task {
            await viewModel.fetchDetails(for: recipeId)
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
        //        .ignoresSafeArea(edges: .top)
        // Cooking Now button
        .safeAreaInset(edge: .bottom) {
            if let detail = viewModel.recipeDetail,
               let steps = detail.analyzedInstructions.first?.steps {
                NavigationLink(destination: CookingModeView(viewModel: CookingModeViewModel(steps: steps, recipeTitle: detail.title))) {
                    Text("Cooking Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding()
                .background(.clear)
            }
        }
        .sheet(isPresented: $isShowingVideo) {
            if let video = viewModel.videoInfo {
                VideoPlayerView(youTubeId: video.youTubeId)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

struct HeaderMediaView: View {
    let videoInfo: VideoInfo?
    let imageUrl: String
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3)).aspectRatio(contentMode: .fit)
            }
            
            if videoInfo != nil {
                Rectangle().fill(.black.opacity(0.4))
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
        }
    }
}
