//
//  CookingModeView.swift
//  E-Food
//

import SwiftUI

struct CookingModeView: View {
    @StateObject var viewModel: CookingModeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                // Timer Circle
                ZStack {
                    // gray circle background
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    
                    // progress bar
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.timeLeft / viewModel.currentDuration))
                        .stroke(viewModel.timeLeft < 10 ? Color.red : Color.orange, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: viewModel.timeLeft)
                    
                    VStack {
                        Text(formatTime(viewModel.timeLeft))
                            .font(.system(size: 40))
                            .bold()
                        
                        Text("Step \(viewModel.currentStepIndex + 1)/\(viewModel.steps.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 250, height: 250)
                .padding(.top, 20)
                
                // Step Instructions
                if viewModel.currentStepIndex < viewModel.steps.count {
                    let step = viewModel.steps[viewModel.currentStepIndex]
                    VStack(spacing: 8) {
                        Text("Step \(step.number)")
                            .font(.title2)
                            .bold()
                        Text(step.step)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 10)
                } else {
                    Text("All done! 🎉")
                        .font(.title2)
                        .padding()
                }
                
                // Controls
                HStack(spacing: 50) {
                    Button(action: {
                        if viewModel.isRunning {
                            viewModel.pauseTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.largeTitle)
                            .padding(25)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.timeLeft == 0)
                    
                    Button(action: {
                        viewModel.nextStep()
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.largeTitle)
                            .padding(25)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.currentStepIndex >= viewModel.steps.count)
                }
                .padding(.top)
                
                // Completed steps
                VStack(alignment: .leading) {
                    DisclosureGroup("Completed Steps (\(viewModel.doneSteps.count))") {
                        if viewModel.doneSteps.isEmpty {
                            Text("No steps completed yet 😅")
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                        } else {
                            ForEach(viewModel.doneSteps) { step in
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        VStack(alignment: .leading) {
                                            Text("Step \(step.number)")
                                                .bold()
                                            Text(step.step)
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Divider()
                                }
                                .padding(.vertical, 3)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Cooking Mode")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Start timer when the view appears
            if !viewModel.steps.isEmpty {
                viewModel.startTimer()
            }
        }
        .onDisappear {
            // Stop timer when leaving
            viewModel.pauseTimer()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let min = Int(time) / 60
        let sec = Int(time) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
