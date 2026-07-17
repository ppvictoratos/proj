import Foundation

struct Constants {
    // INJURY RECOVERY PROTOCOL
    // Organized by category, not day (no 4-day cycle)
    static let injuryExercises: [String: [Exercise]] = [
        "Daily Spine & Posture Reset": [
            Exercise(name: "Dead Hang", program: .injury, muscleGroup: "Spine",
                    description: "20-30 sec, decompresses spine"),
            Exercise(name: "Slow Walk", program: .injury, muscleGroup: "Movement",
                    description: "2-3 min for mobility"),
            Exercise(name: "Standing Pelvic Tilts", program: .injury, muscleGroup: "Core",
                    description: "Against wall for control"),
            Exercise(name: "Hip Circles", program: .injury, muscleGroup: "Mobility",
                    description: "Slow, standing"),
            Exercise(name: "Doorframe Chest Opener", program: .injury, muscleGroup: "Chest",
                    description: "Arms on frame, lean gently"),
            Exercise(name: "Posture Check", program: .injury, muscleGroup: "Posture",
                    description: "Shoulders back, neutral spine")
        ],
        "Core Stretches": [
            Exercise(name: "Single Knee to Chest", program: .injury, muscleGroup: "Core",
                    description: "Each side"),
            Exercise(name: "Figure 4 Stretch", program: .injury, muscleGroup: "Glutes",
                    description: "Pull to chest, each side"),
            Exercise(name: "Hamstring Stretch", program: .injury, muscleGroup: "Hamstrings",
                    description: "With toe point"),
            Exercise(name: "Standing Calf Stretch", program: .injury, muscleGroup: "Calves",
                    description: "Against wall"),
            Exercise(name: "Couch Stretch", program: .injury, muscleGroup: "Hip Flexors",
                    description: "Deep, gentle stretch"),
            Exercise(name: "Child's Pose", program: .injury, muscleGroup: "Spine",
                    description: "60 sec hold")
        ],
        "Reset Fast": [
            Exercise(name: "Knees to Chest Rocks", program: .injury, muscleGroup: "Spine",
                    description: "Rock side-to-side"),
            Exercise(name: "Diaphragmatic Breathing", program: .injury, muscleGroup: "Breathing",
                    description: "5 deep breaths")
        ]
    ]

    // TETRAD ATHLETIC CYCLE
    static let tetradExercises: [TetradDay: [Exercise]] = [
        .day1: [
            Exercise(name: "KB Swings", program: .tetrad, tetradDay: .day1, muscleGroup: "Posterior Chain",
                    description: "Explosive hip drive", sets: 3, reps: 10),
            Exercise(name: "Med Ball Rotational Throws", program: .tetrad, tetradDay: .day1, muscleGroup: "Explosive",
                    description: "Golf power translation", sets: 3, reps: 8),
            Exercise(name: "Speed Pull-Ups", program: .tetrad, tetradDay: .day1, muscleGroup: "Pull",
                    description: "Explosive upward, 2-sec lower", sets: 4, reps: 5),
            Exercise(name: "Goblet Squats", program: .tetrad, tetradDay: .day1, muscleGroup: "Legs",
                    description: "Mobility and volume", sets: 3, reps: 12)
        ],
        .day2: [
            Exercise(name: "Weighted Pull-Ups", program: .tetrad, tetradDay: .day2, muscleGroup: "Pull",
                    description: "Heavy with dipping belt, 3-min rest", sets: 4, reps: 5),
            Exercise(name: "Deadlifts", program: .tetrad, tetradDay: .day2, muscleGroup: "Posterior Chain",
                    description: "Posterior chain foundation", sets: 3, reps: 5),
            Exercise(name: "Overhead Press", program: .tetrad, tetradDay: .day2, muscleGroup: "Push",
                    description: "Barbell, strict form", sets: 3, reps: 6),
            Exercise(name: "Hanging Leg Raises", program: .tetrad, tetradDay: .day2, muscleGroup: "Core",
                    description: "Max reps, strict control", sets: 3, reps: 0)
        ],
        .day3: [
            Exercise(name: "Lap Swimming", program: .tetrad, tetradDay: .day3, muscleGroup: "Cardio",
                    description: "20-30 min, moderate pace, tissue flushing"),
            Exercise(name: "Rotational Mobility", program: .tetrad, tetradDay: .day3, muscleGroup: "Mobility",
                    description: "T-spine flow, golf mechanics, 15 min")
        ],
        .day4: [
            Exercise(name: "Chest-to-Bar Pull-Ups", program: .tetrad, tetradDay: .day4, muscleGroup: "Pull",
                    description: "Hard hold at top", sets: 3, reps: 10),
            Exercise(name: "Back Squats", program: .tetrad, tetradDay: .day4, muscleGroup: "Legs",
                    description: "Volume and stability", sets: 3, reps: 10),
            Exercise(name: "Dumbbell Incline Press", program: .tetrad, tetradDay: .day4, muscleGroup: "Push",
                    description: "Upper chest and shoulders", sets: 3, reps: 10),
            Exercise(name: "Landmine Core Twists", program: .tetrad, tetradDay: .day4, muscleGroup: "Core",
                    description: "Rotational core work", sets: 3, reps: 12)
        ]
    ]

    // Styling
    static let darkBackground = #colorLiteral(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
    static let accentColor = #colorLiteral(red: 0.2, green: 0.8, blue: 0.8, alpha: 1)  // Cyan
    static let textPrimary = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let textSecondary = #colorLiteral(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
}
