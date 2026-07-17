import SwiftUI

struct UpcomingWorkoutCard: View {
    let day: TetradDay
    let exercises: [Exercise]
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text(day.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.cyan)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(exercises, id: \.id) { exercise in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 4, height: 4)
                        Text(exercise.name)
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text(exercise.muscleGroup)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }

            Button(action: action) {
                Text("Start Workout")
                    .font(.system(weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.cyan)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(UIColor.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}

#Preview {
    UpcomingWorkoutCard(
        day: .day1,
        exercises: Constants.tetradExercises[.day1] ?? [],
        action: {}
    )
}
