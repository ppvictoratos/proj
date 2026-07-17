import SwiftUI
import SwiftData

struct HistoryView: View {
    @State private var sessions: [WorkoutSession] = []
    @State private var selectedSession: WorkoutSession?
    @Query(sort: [SortDescriptor(\.date, order: .reverse)]) var allSessions: [WorkoutSession]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.darkBG.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("History")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)

                    if allSessions.isEmpty {
                        Text("No workouts yet")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        List {
                            ForEach(allSessions, id: \.id) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.tetradDay.name)
                                            .font(.caption)
                                            .foregroundColor(Theme.textPrimary)
                                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption2)
                                            .foregroundColor(Theme.textSecondary)
                                        Text("\(session.exercises.count) exercises")
                                            .font(.caption2)
                                            .foregroundColor(Theme.accentCyan)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView()
}
