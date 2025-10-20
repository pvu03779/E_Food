import Foundation
import Combine

@MainActor
class CookingModeViewModel: ObservableObject {
    let steps: [InstructionStep]
    let recipeTitle: String
    
    @Published var currentStepIndex = 0
    @Published var completedSteps: [InstructionStep] = []
    @Published var timeRemaining: TimeInterval
    @Published var isTimerRunning = false
    
    // This now tracks the duration of the CURRENT step and is @Published
    @Published var currentStepDuration: TimeInterval
    
    private var timer: AnyCancellable?

    init(steps: [InstructionStep], recipeTitle: String) {
        self.steps = steps
        self.recipeTitle = recipeTitle
        // Set the initial duration for the first step
        let initialDuration = Self.parseTime(from: steps.first?.step ?? "")
        // Use a default of 1 second if no time is found to prevent division by zero
        let safeInitialDuration = initialDuration > 0 ? initialDuration : 1
        // Both properties are now initialized from the local constant.
        self.currentStepDuration = safeInitialDuration
        self.timeRemaining = safeInitialDuration
    }
    
    func startTimer() {
        guard timeRemaining > 0 else { return }
        isTimerRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self, self.isTimerRunning else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerCompleted()
            }
        }
    }
    
    func pauseTimer() {
        isTimerRunning = false
        timer?.cancel()
    }
    
    func nextStep() {
        pauseTimer()
        if let currentStep = steps.get(at: currentStepIndex) {
            if !completedSteps.contains(where: { $0.id == currentStep.id }) {
                 completedSteps.append(currentStep)
            }
        }
        
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            let nextStepDuration = Self.parseTime(from: steps[currentStepIndex].step)
            self.currentStepDuration = nextStepDuration > 0 ? nextStepDuration : 1
            self.timeRemaining = self.currentStepDuration
            startTimer()
        } else {
            // Mark the final step as complete if not already
            if let lastStep = steps.last, !completedSteps.contains(where: { $0.id == lastStep.id }) {
                completedSteps.append(lastStep)
            }
            currentStepIndex += 1
        }
    }
    
    private func timerCompleted() {
        pauseTimer()
        NotificationManager.shared.scheduleNotification(
            title: recipeTitle,
            body: "Step \(steps[currentStepIndex].number) is complete!",
            timeInterval: 1
        )
    }
    
    static private func parseTime(from text: String) -> TimeInterval {
        do {
            let regex = try NSRegularExpression(pattern: #"(\d+)\s+(minute|hour)s?"#, options: .caseInsensitive)
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                if let numberRange = Range(match.range(at: 1), in: text),
                   let unitRange = Range(match.range(at: 2), in: text) {
                    let number = Double(text[numberRange]) ?? 0
                    let unit = String(text[unitRange]).lowercased()
                    return unit == "hour" ? number * 3600 : number * 60
                }
            }
        } catch {}
        return 0
    }
}

extension Array {
    func get(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

