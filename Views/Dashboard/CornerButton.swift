import SwiftUI

struct CornerButton: View {
    let exercise: Exercise
    let action: () -> Void

    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    private let stoneGrey = Color(red: 0.17, green: 0.17, blue: 0.17)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 16))
                Text(exercise.name)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .foregroundColor(textLight)
            .frame(width: 50, height: 50)
            .background(stoneGrey)
            .cornerRadius(8)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.04, green: 0.04, blue: 0.04).ignoresSafeArea()
        CornerButton(
            exercise: Exercise(name: "KB Swings", program: .tetrad, tetradDay: .day1,
                              muscleGroup: "Posterior", description: "Power"),
            action: {}
        )
    }
}
