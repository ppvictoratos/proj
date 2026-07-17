import SwiftUI

struct TetradHistoryRow: View {
    let session: WorkoutSession

    private let stoneGrey = Color(red: 0.17, green: 0.17, blue: 0.17)
    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)
    private let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.63)

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.tetradDay.name)
                    .font(.caption)
                    .foregroundColor(textLight)
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(textSecondary)
            }
            Spacer()
            Text("\(session.exercises.count) exercises")
                .font(.caption2)
                .padding(4)
                .background(accentCyan.opacity(0.2))
                .foregroundColor(accentCyan)
                .cornerRadius(4)
        }
        .padding(12)
        .background(stoneGrey)
        .cornerRadius(8)
    }
}

#Preview {
    ZStack {
        Color(red: 0.04, green: 0.04, blue: 0.04).ignoresSafeArea()
        TetradHistoryRow(session: WorkoutSession(tetradDay: .day1))
            .padding()
    }
}
