import SwiftUI

struct ExerciseListView: View {
    @Binding var activeView: String?

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: { activeView = nil }) {
                        Text("← Back")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(EntrakeiaPalette.blue)
                    }
                    Spacer()
                }
                .padding(12)

                Text("EXERCISES")
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(EntrakeiaPalette.accent)
                    .padding(12)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(["KB Swings", "Weighted Pull-Ups", "Deadlifts", "Overhead Press", "Back Squats", "Incline Press", "Skull Crushers", "Dumbbell Curls"], id: \.self) { name in
                            HStack {
                                Text(name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(EntrakeiaPalette.text)
                                Spacer()
                            }
                            .padding(12)
                            .borderBottom(height: 0.5, color: EntrakeiaPalette.card)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ExerciseListView(activeView: .constant(nil))
}
