import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var cycles: [TetradCycle]
    @State private var session = SessionManager()
    @State private var scrubProgress: CGFloat = 0

    var body: some View {
        ZStack {
            EnkrateiaPalette.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("ΕΝΤΡΑΚΕΡΙΑ")
                    .font(.system(size: 15, weight: .semibold))
                    .kerning(6)
                    .foregroundStyle(EnkrateiaPalette.bronze)
                    .padding(.top, 8)

                TetradRibbonView(cycleDays: SessionManager.ribbonDays(cycleCount: cycles.count),
                                 scrubProgress: $scrubProgress)

                Text("DAY \(session.activeDayIndex + 1) OF 4")
                    .font(.system(size: 11, weight: .medium))
                    .kerning(2)
                    .foregroundStyle(EnkrateiaPalette.line)

                Spacer(minLength: 0)

                TodayVertexView(exercises: session.exercises,
                                state: session.state(at:),
                                onTap: session.select)

                Spacer(minLength: 0)
            }
        }
        .onAppear { session.bootstrap(in: context) }
        .sheet(item: $session.activeExercise) { exercise in
            ExerciseModal(exercise: exercise, session: session) {
                session.completeExercise(exercise, in: context)
            }
            .presentationDetents([.large])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TetradCycle.self, WorkoutSession.self, ExerciseLog.self],
                        inMemory: true)
}
