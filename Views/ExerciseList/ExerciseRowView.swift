import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    @State private var weight = 45.0

    private let stoneGrey = Color(red: 0.17, green: 0.17, blue: 0.17)
    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)
    private let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.63)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.caption)
                        .foregroundColor(textLight)
                    Text(exercise.muscleGroup)
                        .font(.caption2)
                        .foregroundColor(textSecondary)
                }
                Spacer()
                Text(String(format: "%.0f lbs", weight))
                    .font(.caption)
                    .foregroundColor(accentCyan)
            }

            Slider(value: $weight, in: 0...300, step: 5)
                .tint(accentCyan)
        }
        .padding(12)
        .background(stoneGrey)
        .cornerRadius(8)
    }
}

#Preview {
    ZStack {
        Color(red: 0.04, green: 0.04, blue: 0.04).ignoresSafeArea()
        ExerciseRowView(exercise: Exercise(
            name: "Deadlifts", program: .tetrad, tetradDay: .day2,
            muscleGroup: "Posterior", description: "Heavy"
        ))
        .padding()
    }
}
