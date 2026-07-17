import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    let exercise: Exercise
    let modelContext: ModelContext

    @State private var sets = ""
    @State private var reps = ""
    @State private var weight = 45.0
    @State private var usedBelt = false
    @State private var showTimer = false
    @StateObject private var sessionVM: WorkoutSessionViewModel
    @Environment(\.dismiss) var dismiss

    private let marbleBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let stoneGrey = Color(red: 0.17, green: 0.17, blue: 0.17)
    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)
    private let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.63)

    init(exercise: Exercise, modelContext: ModelContext) {
        self.exercise = exercise
        self.modelContext = modelContext

        let session = WorkoutSession(tetradDay: exercise.tetradDay ?? .day1)
        _sessionVM = StateObject(wrappedValue: WorkoutSessionViewModel(
            session: session,
            modelContext: modelContext
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                marbleBlack.ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(textLight)
                            Text(exercise.muscleGroup)
                                .font(.caption)
                                .foregroundColor(textSecondary)
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(accentCyan)
                        }
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.caption)
                            .foregroundColor(textSecondary)
                        Text(exercise.description)
                            .font(.caption)
                            .foregroundColor(textLight)
                            .lineLimit(4)
                    }
                    .padding(12)
                    .background(stoneGrey)
                    .cornerRadius(8)

                    // Logging form
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sets")
                                    .font(.caption)
                                    .foregroundColor(textSecondary)
                                TextField("", text: $sets)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .keyboardType(.numberPad)
                                    .foregroundColor(textLight)
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Reps")
                                    .font(.caption)
                                    .foregroundColor(textSecondary)
                                TextField("", text: $reps)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .keyboardType(.numberPad)
                                    .foregroundColor(textLight)
                            }
                        }

                        WeightSlider(weight: $weight)

                        Toggle("Dipping Belt", isOn: $usedBelt)
                            .tint(accentCyan)
                            .foregroundColor(textLight)
                    }
                    .padding(12)
                    .background(stoneGrey)
                    .cornerRadius(8)

                    HStack(spacing: 12) {
                        Button(action: {
                            if let s = Int(sets), let r = Int(reps) {
                                sessionVM.logExercise(
                                    exerciseName: exercise.name,
                                    sets: s,
                                    reps: r,
                                    weight: weight,
                                    usedBelt: usedBelt
                                )
                                dismiss()
                            }
                        }) {
                            Text("Log")
                                .font(.system(weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(accentCyan)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }

                        Button(action: { showTimer = true }) {
                            Text("Rest")
                                .font(.system(weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(stoneGrey)
                                .foregroundColor(accentCyan)
                                .cornerRadius(8)
                        }
                    }

                    Spacer()
                }
                .padding(16)
            }
            .sheet(isPresented: $showTimer) {
                ExerciseTimerModal(viewModel: sessionVM)
            }
        }
    }
}

#Preview {
    ExerciseDetailView(
        exercise: Exercise(name: "KB Swings", program: .tetrad, tetradDay: .day1,
                          muscleGroup: "Posterior", description: "Explosive hip drive"),
        modelContext: .preview
    )
}
