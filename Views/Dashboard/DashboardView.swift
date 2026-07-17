import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var viewModel: TetradCycleViewModel
    @State private var selectedExercise: Exercise?
    @State private var showExerciseDetail = false
    @State private var activeTab: String = "dashboard"

    private let modelContext: ModelContext
    private let marbleBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _viewModel = StateObject(wrappedValue: TetradCycleViewModel(modelContext: modelContext))
    }

    var body: some View {
        ZStack {
            marbleBlack.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("ENKRATEIA")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(textLight)

                RotatedSquareView(exercises: viewModel.currentExercises) { exercise in
                    selectedExercise = exercise
                    showExerciseDetail = true
                }

                Spacer()

                // Bottom buttons
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Text("EXERCISES")
                            .font(.system(weight: .semibold, size: 14))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(accentCyan)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }

                    Button(action: {}) {
                        Text("TETRADS")
                            .font(.system(weight: .semibold, size: 14))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(accentCyan.opacity(0.2))
                            .foregroundColor(accentCyan)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(20)

            .sheet(isPresented: $showExerciseDetail) {
                if let exercise = selectedExercise {
                    ExerciseDetailView(exercise: exercise, modelContext: modelContext)
                }
            }
        }
    }
}

#Preview {
    DashboardView(modelContext: .preview)
        .modelContainer(ModelContainerProvider.shared.container)
}
