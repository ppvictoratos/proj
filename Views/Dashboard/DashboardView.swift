import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var viewModel: TetradCycleViewModel
    @State private var showWorkoutView = false
    @State private var activeSession: WorkoutSession?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _viewModel = StateObject(wrappedValue: TetradCycleViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.darkBG.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Enkrateia")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.textPrimary)

                    // Show program-specific UI
                    if viewModel.selectedProgram == .tetrad {
                        CycleProgressView(currentDay: viewModel.cycle.currentDay)

                        UpcomingWorkoutCard(
                            day: viewModel.cycle.currentDay,
                            exercises: viewModel.currentExercises
                        ) {
                            activeSession = viewModel.createWorkoutSession(
                                for: viewModel.cycle.currentDay
                            )
                            showWorkoutView = true
                        }
                    } else {
                        // Injury recovery: show daily routine, no cycle
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Recovery Routine")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            Text("Follow this every day to aid recovery")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(16)
                        .background(Theme.cardBG)
                        .cornerRadius(12)

                        UpcomingWorkoutCard(
                            day: .day1,  // Dummy day for layout
                            exercises: viewModel.currentExercises
                        ) {
                            activeSession = viewModel.createWorkoutSession(
                                for: .day1  // Use day1 for injury protocol sessions
                            )
                            showWorkoutView = true
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)

                        if let lastDate = viewModel.lastWorkoutDate() {
                            Text("Last: \(lastDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        } else {
                            Text("No workouts yet. Time to begin.")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .padding(12)
                    .background(Theme.cardBG)
                    .cornerRadius(8)

                    Spacer()
                }
                .padding(16)
            }
            .navigationDestination(isPresented: $showWorkoutView) {
                if let session = activeSession {
                    WorkoutView(session: session, modelContext: modelContext)
                }
            }
        }
    }
}

#Preview {
    DashboardView(modelContext: .preview)
}
