import SwiftUI

struct SessionDetailView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).opacity(0.1).ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.tetradDay.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text(session.date.formatted(date: .complete, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(session.exercises, id: \.id) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(log.exerciseName)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Spacer()
                                if log.usedDippingBelt {
                                    Text("Belt")
                                        .font(.caption2)
                                        .padding(4)
                                        .background(Color.cyan.opacity(0.2))
                                        .foregroundColor(.cyan)
                                        .cornerRadius(4)
                                }
                            }
                            Text("\(log.sets)×\(log.reps)" + (log.weight.map { " @ \($0) lbs" } ?? ""))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(Color(UIColor.systemGray6).opacity(0.3))
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
