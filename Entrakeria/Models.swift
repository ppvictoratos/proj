import Foundation
import SwiftData

@Model final class TetradCycle {
    var startDate: Date
    @Relationship(deleteRule: .cascade) var sessions: [WorkoutSession]
    init(startDate: Date = .now) { self.startDate = startDate; sessions = [] }
}

@Model final class WorkoutSession {
    var dayIndex: Int          // 0...3, position in the tetrad
    var date: Date
    var totalDuration: TimeInterval
    @Relationship(deleteRule: .cascade) var logs: [ExerciseLog]
    init(dayIndex: Int, date: Date = .now) {
        self.dayIndex = dayIndex; self.date = date
        totalDuration = 0; logs = []
    }
}

@Model final class ExerciseLog {
    var exerciseName: String
    var reps: Int
    var duration: TimeInterval
    var completedAt: Date?
    init(exerciseName: String, reps: Int, duration: TimeInterval) {
        self.exerciseName = exerciseName; self.reps = reps; self.duration = duration
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let reps: Int
    let seconds: Int
    let stickFigureSymbol: String   // SF Symbol stand-in, swap later
}

// Backend-swappable list
let defaultExercises: [Exercise] = [
    .init(name: "Boulder Lift", reps: 8, seconds: 40, stickFigureSymbol: "figure.strengthtraining.traditional"),
    .init(name: "Sprint", reps: 1, seconds: 30, stickFigureSymbol: "figure.run"),
    .init(name: "Wrestling Hold", reps: 5, seconds: 45, stickFigureSymbol: "figure.wrestling"),
    .init(name: "Discus Throw", reps: 10, seconds: 35, stickFigureSymbol: "figure.disc.sports")
]
