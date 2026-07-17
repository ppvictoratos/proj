import Foundation
import SwiftData

@MainActor
final class TetradCycleViewModel: ObservableObject {
    @Published var cycle: TetradCycle
    @Published var currentExercises: [Exercise] = []
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var selectedProgram: Program = .tetrad {
        didSet {
            updateExercisesForProgram()
        }
    }

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.cycle = TetradCycleService.shared.getOrCreateCycle()
        fetchWorkoutSessions()
        updateExercisesForProgram()
    }

    func updateExercisesForProgram() {
        currentExercises = TetradCycleService.shared.getCurrentExercises(for: selectedProgram)
    }

    func fetchWorkoutSessions() {
        let descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        workoutSessions = (try? modelContext.fetch(descriptor)) ?? []
    }

    func advanceDay() {
        TetradCycleService.shared.advanceToNextDay()
        cycle = TetradCycleService.shared.getOrCreateCycle()
        updateExercisesForProgram()
    }

    func createWorkoutSession(for day: TetradDay) -> WorkoutSession {
        let session = WorkoutSession(date: Date(), tetradDay: day)
        modelContext.insert(session)
        try? modelContext.save()
        fetchWorkoutSessions()
        return session
    }

    func lastWorkoutDate() -> Date? {
        return workoutSessions.first?.date
    }
}
