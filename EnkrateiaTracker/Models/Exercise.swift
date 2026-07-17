import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let program: Program
    let tetradDay: TetradDay?  // Nil for injury program (which doesn't have days)
    let muscleGroup: String
    let description: String
    let sets: Int?  // Optional default sets for the program
    let reps: Int?  // Optional default reps for the program

    init(id: UUID = UUID(), name: String, program: Program, tetradDay: TetradDay? = nil,
         muscleGroup: String, description: String, sets: Int? = nil, reps: Int? = nil) {
        self.id = id
        self.name = name
        self.program = program
        self.tetradDay = tetradDay
        self.muscleGroup = muscleGroup
        self.description = description
        self.sets = sets
        self.reps = reps
    }
}
