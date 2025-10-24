//
//  CookingModeViewModel.swift
//  E-Food
//

import Foundation
import Combine

@MainActor
class CookingModeViewModel: ObservableObject {
    
    var steps: [InstructionStep]
    var title: String
    
    @Published var currentStepIndex = 0
    @Published var doneSteps: [InstructionStep] = []
    @Published var timeLeft: TimeInterval = 0
    @Published var isRunning = false
    @Published var currentDuration: TimeInterval = 0
    
    private var timerThing: AnyCancellable?
    
    init(steps: [InstructionStep], title: String) {
        self.steps = steps
        self.title = title
        
        // try to get the time from first step
        let t = Self.findTime(from: steps.first?.step ?? "")
        self.currentDuration = t > 0 ? t : 1
        self.timeLeft = self.currentDuration
    }
    
    func startTimer() {
        if timeLeft <= 0 {
            print("Timer already done.")
            return
        }
        
        isRunning = true
        timerThing = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.isRunning {
                    if self.timeLeft > 0 {
                        self.timeLeft -= 1
                    } else {
                        self.stepDone()
                    }
                }
            }
    }
    
    func pauseTimer() {
        isRunning = false
        timerThing?.cancel()
        print("Timer paused at \(timeLeft) seconds left")
    }
    
    func nextStep() {
        pauseTimer()
        
        if currentStepIndex < steps.count {
            let current = steps[currentStepIndex]
            if !doneSteps.contains(where: { $0.id == current.id }) {
                doneSteps.append(current)
            }
        }
        
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            let nextDuration = Self.findTime(from: steps[currentStepIndex].step)
            self.currentDuration = nextDuration > 0 ? nextDuration : 1
            self.timeLeft = self.currentDuration
            print("Moving to next step: \(currentStepIndex + 1)")
            startTimer()
        } else {
            print("All steps finished!")
            if let last = steps.last, !doneSteps.contains(where: { $0.id == last.id }) {
                doneSteps.append(last)
            }
        }
    }
    
    private func stepDone() {
        pauseTimer()
        print("Step \(currentStepIndex + 1) done!")
        NotificationManager.shared.scheduleNotification(
            title: title,
            body: "Step \(steps[currentStepIndex].number) is done!",
            timeInterval: 1
        )
    }
    
    static func findTime(from text: String) -> TimeInterval {
        // trying to find minutes/hours in the text
        do {
            let regex = try NSRegularExpression(pattern: #"(\d+)\s+(minute|hour)s?"#, options: .caseInsensitive)
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches {
                if let numRange = Range(match.range(at: 1), in: text),
                   let unitRange = Range(match.range(at: 2), in: text) {
                    let num = Double(text[numRange]) ?? 0
                    let unit = text[unitRange].lowercased()
                    if unit == "hour" {
                        return num * 3600
                    } else {
                        return num * 60
                    }
                }
            }
        } catch {
            print("regex fail: \(error)")
        }
        return 0
    }
}

extension Array {
    func safeGet(_ index: Int) -> Element? {
        if indices.contains(index) {
            return self[index]
        } else {
            print("Index \(index) out of range!")
            return nil
        }
    }
}
