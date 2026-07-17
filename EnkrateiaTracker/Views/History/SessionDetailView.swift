import SwiftUI

struct SessionDetailView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.darkBG.ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.tetradDay.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Text(session.date.formatted(date: .complete, time: .shortened))
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(session.exercises, id: \.id) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(log.exerciseName)
                                    .font(.caption)
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                if log.usedDippingBelt {
                                    Text("Belt")
                                        .font(.caption2)
                                        .padding(4)
                                        .background(Theme.accentCyan.opacity(0.2))
                                        .foregroundColor(Theme.accentCyan)
                                        .cornerRadius(4)
                                }
                            }
                            Text("\(log.sets)×\(log.reps)" + (log.weight.map { " @ \($0) lbs" } ?? ""))
                                .font(.caption2)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(8)
                        .background(Theme.cardBG)
                        .cornerRadius(6)
                    }
                }

                Spacer()
            }
            .padding(16)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SessionDetailView(session: WorkoutSession(tetradDay: .day1))
}
