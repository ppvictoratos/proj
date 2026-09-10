import SwiftUI

struct ExerciseListView: View {
    @Binding var showExerciseList: Bool

    let exercises = [
        ("Pelvic Tilts", "29 slow reps, flatback"),
        ("Glute Bridges", "2x12, 2 sec squeeze"),
        ("Ham Bridges", "2x12, 2 sec squeeze"),
        ("Clamshells", "2x20 each side"),
        ("Lateral Leg Lifts", "2x10"),
        ("Child's Pose", "60 sec"),
        ("Cat Cows", "3x10"),
        ("Pigeon", "60 sec each side"),
        ("90/90 Hip Stretch", "60 sec each side"),
        ("Dead Bug", "3x8 each side"),
        ("Curl Up L/R", "2x10 each"),
        ("Bear Planks w/ KB Drag", ""),
        ("Lateral Step Down", ""),
        ("Arm Band Pull", ""),
        ("Goblet Squats", "29 reps, light"),
        ("Lunges with Blocks", "20-30 sec hold"),
        ("Single Leg RDL", "2x10 each"),
        ("Standing Hip Circles", "10 each direction"),
        ("Flexed Arm Hang", "1 min"),
        ("15 Min Reset", "shake, cat-cow, etc"),
        ("7 Min Breath Work", "4-in, 6-out"),
        ("Dead Hang", "20-30 sec"),
        ("Slow Walk", "2-3 min"),
        ("Doorframe Chest Opener", ""),
        ("Single Knee to Chest", "each side"),
        ("Figure 4 Pull", "each side"),
        ("Hamstring Stretch", "w/ toe point"),
        ("Couch Stretch", ""),
        ("KB Swings (Day 1)", "3x10 reps"),
        ("Med Ball Throws (Day 1)", "3x8 per side"),
        ("Bodyweight Pull-Ups (Day 1)", "4x5 explosive"),
        ("KB Goblet Squats (Day 1)", "3x12"),
        ("Weighted Pull-Ups (Day 2)", "4x4-6 heavy"),
        ("Barbell Deadlift (Day 2)", "3x5"),
        ("Overhead Press (Day 2)", "3x6"),
        ("Hanging Leg Raises (Day 2)", "3x max"),
        ("Swimming (Day 3)", "20-30 min"),
        ("Rotational Mobility (Day 3)", "15 min"),
        ("Pull-Ups Chest-to-Bar (Day 4)", "3x8-12"),
        ("Barbell Back Squats (Day 4)", "3x10"),
        ("Dumbbell Incline Press (Day 4)", "3x10"),
        ("Landmine Core Twists (Day 4)", "3x12 per side"),
        ("Dumbbell Skull Crushers", "20"),
        ("Overhead Triceps Extension", ""),
        ("Standing Dumbbell Curls", ""),
        ("Hammer Curls", ""),
        ("Wrist Curls", "")
    ]

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { showExerciseList = false }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(EntrakeiaPalette.blue)
                    }

                    Spacer()

                    Text("EXERCISES")
                        .font(.system(size: 18, weight: .semibold))
                        .tracking(3)
                        .foregroundStyle(EntrakeiaPalette.accent)

                    Spacer()

                    Color.clear.frame(width: 50)
                }
                .padding(20)
                .borderBottom(height: 1, color: EntrakeiaPalette.line)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(exercises, id: \.0) { name, reps in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(EntrakeiaPalette.text)

                                if !reps.isEmpty {
                                    Text(reps)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundStyle(EntrakeiaPalette.line)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .borderBottom(height: 1, color: EntrakeiaPalette.card)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 1000)
    }
}

extension View {
    func borderBottom(height: CGFloat, color: Color) -> some View {
        VStack {
            self
            Divider()
                .frame(height: height)
                .background(color)
        }
    }
}

#Preview {
    ExerciseListView(showExerciseList: .constant(true))
}
