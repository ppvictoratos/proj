import Foundation
import SwiftData

final class TetradCycleService {
    static let shared = TetradCycleService()

    private var modelContext: ModelContext?

    func setup(with context: ModelContext) {
        self.modelContext = context
    }

    func getOrCreateCycle() -> TetradCycle {
        guard let context = modelContext else { return TetradCycle() }

        let descriptor = FetchDescriptor<TetradCycle>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let newCycle = TetradCycle()
        context.insert(newCycle)
        try? context.save()
        return newCycle
    }

    func getCurrentDay() -> TetradDay {
        return getOrCreateCycle().currentDay
    }

    func advanceToNextDay() {
        let cycle = getOrCreateCycle()
        cycle.advanceDay()
        try? modelContext?.save()
    }

    // NEW: Get exercises for current program and day
    func getExercises(for program: Program, day: TetradDay? = nil) -> [Exercise] {
        switch program {
        case .tetrad:
            guard let day = day else { return [] }
            return Constants.tetradExercises[day] ?? []
        case .injury:
            // Injury protocol: return all exercises organized by category
            return Constants.injuryExercises.values.flatMap { $0 }
        }
    }

    // NEW: Get exercises for current program only
    func getCurrentExercises(for program: Program) -> [Exercise] {
        let day = program == .tetrad ? getCurrentDay() : nil
        return getExercises(for: program, day: day)
    }
}
