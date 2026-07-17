import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel: TetradCycleViewModel

    private let marbleBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)

    var body: some View {
        ZStack {
            marbleBlack.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("EXERCISES")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(textLight)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.currentExercises, id: \.id) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

#Preview {
    ExerciseListView(viewModel: TetradCycleViewModel(modelContext: .preview))
        .modelContainer(ModelContainerProvider.shared.container)
}
