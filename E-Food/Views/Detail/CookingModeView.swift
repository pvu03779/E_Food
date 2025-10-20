//
//  CookingModeView.swift
//  E-Food
//

import SwiftUI

struct CookingModeView: View {
    @StateObject var viewModel: CookingModeViewModel
    
    var body: some View {
        // The entire view is now wrapped in a ScrollView.
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    // Background track
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.1)
                        .foregroundColor(.gray)
                    
                    // Progress bar that counts down (from full to empty)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(viewModel.timeRemaining / viewModel.currentStepDuration))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(viewModel.timeRemaining <= 10 ? .red : .orange) // Change color when time is low
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: viewModel.timeRemaining)
                    
                    // Timer text and step counter
                    VStack {
                        Text(timeString(from: viewModel.timeRemaining))
                            .font(.largeTitle)
                            .bold()
                        
                        if viewModel.currentStepIndex < viewModel.steps.count {
                             Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.steps.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(width: 250, height: 250)
                .padding(.top, 20)
                
                // --- STEP INSTRUCTIONS ---
                if let currentStep = viewModel.steps.get(at: viewModel.currentStepIndex) {
                    Text("Step \(currentStep.number)")
                        .font(.title).bold()
                        .padding(.top)
                    Text(currentStep.step)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("You're all done! Enjoy your meal. 🎉")
                        .font(.title).bold().padding()
                }
                
                // --- TIMER CONTROLS ---
                HStack(spacing: 40) {
                    Button(action: {
                        viewModel.isTimerRunning ? viewModel.pauseTimer() : viewModel.startTimer()
                    }) {
                        Image(systemName: viewModel.isTimerRunning ? "pause.fill" : "play.fill")
                            .font(.largeTitle).foregroundColor(.white).padding(30)
                            .background(Color.orange).clipShape(Circle())
                    }
                    .disabled(viewModel.timeRemaining == 0 && viewModel.isTimerRunning == false)
                    
                    Button(action: viewModel.nextStep) {
                        Image(systemName: "arrow.right")
                            .font(.largeTitle).foregroundColor(.white).padding(30)
                            .background(Color.gray).clipShape(Circle())
                    }
                    .disabled(viewModel.currentStepIndex >= viewModel.steps.count)
                }
                .padding()
                
                // --- COMPLETED STEPS SECTION ---
                // This is a collapsible section to show completed steps.
                DisclosureGroup {
                    if viewModel.completedSteps.isEmpty {
                        Text("No steps completed yet.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.completedSteps) { step in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    VStack(alignment: .leading) {
                                        Text("Step \(step.number)").fontWeight(.bold)
                                        Text(step.step).foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                        }
                        .padding(.top)
                    }
                } label: {
                    HStack {
                        Text("Completed Steps")
                            .font(.headline)
                        Spacer()
                        Text("\(viewModel.completedSteps.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

            }
        }
        .onAppear {
            if !viewModel.steps.isEmpty {
                viewModel.startTimer()
            }
        }
        .onDisappear {
            viewModel.pauseTimer()
        }
        .navigationTitle("Cooking Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
