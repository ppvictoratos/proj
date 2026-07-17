import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var tetradDay: TetradDay
    var exercises: [ExerciseLog]
    var completed: Bool

    init(id: UUID = UUID(), date: Date = Date(), tetradDay: TetradDay,
         exercises: [ExerciseLog] = [], completed: Bool = false) {
        self.id = id
        self.date = date
        self.tetradDay = tetradDay
        self.exercises = exercises
        self.completed = completed
    }
}
