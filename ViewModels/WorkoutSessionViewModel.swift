import Foundation
import SwiftData

@MainActor
final class WorkoutSessionViewModel: ObservableObject {
    @Published var session: WorkoutSession
    @Published var timerIsRunning = false
    @Published var remainingSeconds = 0
    @Published var selectedExercise: Exercise?
    @Published var currentSets = ""
    @Published var currentReps = ""
    @Published var currentWeight: Double? = nil
    @Published var usedBelt = false

    private var timer: Timer?
    private var modelContext: ModelContext

    init(session: WorkoutSession, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
    }

    func startRestTimer(seconds: Int) {
        remainingSeconds = seconds
        timerIsRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.remainingSeconds -= 1
            if self?.remainingSeconds ?? 0 <= 0 {
                self?.stopRestTimer()
            }
        }
    }

    func stopRestTimer() {
        timer?.invalidate()
        timer = nil
        timerIsRunning = false
        remainingSeconds = 0
    }

    func logExercise(exerciseName: String, sets: Int, reps: Int, weight: Double?, usedBelt: Bool) {
        let log = ExerciseLog(
            exerciseName: exerciseName,
            sets: sets,
            reps: reps,
            weight: weight,
            usedDippingBelt: usedBelt,
            workoutSessionID: session.id
        )
        session.exercises.append(log)
        modelContext.insert(log)
        try? modelContext.save()

        clearForm()
    }

    func completeSession() {
        session.completed = true
        try? modelContext.save()
    }

    private func clearForm() {
        currentSets = ""
        currentReps = ""
        currentWeight = nil
        usedBelt = false
        selectedExercise = nil
    }
}
