import Foundation
import SwiftData

@Model
final class ExerciseLog {
    var exerciseName: String
    var sets: Int
    var reps: Int
    var weight: Double?  // Optional for bodyweight exercises
    var usedDippingBelt: Bool
    var timestamp: Date
    var workoutSessionID: UUID

    init(exerciseName: String, sets: Int, reps: Int, weight: Double? = nil,
         usedDippingBelt: Bool = false, workoutSessionID: UUID) {
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.usedDippingBelt = usedDippingBelt
        self.timestamp = Date()
        self.workoutSessionID = workoutSessionID
    }
}
