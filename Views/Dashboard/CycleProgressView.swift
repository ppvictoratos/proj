import SwiftUI

struct CycleProgressView: View {
    let currentDay: TetradDay

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Theme.textSecondary.opacity(0.2), lineWidth: 2)
                    .frame(width: 200, height: 200)

                // Progress arc
                Circle()
                    .trim(from: 0, to: Double(currentDay.rawValue) / 4.0)
                    .stroke(Theme.accentCyan, lineWidth: 4)
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 8) {
                    Text("Day \(currentDay.rawValue)")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.textPrimary)
                    Text(currentDay.name)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }

            HStack(spacing: 12) {
                ForEach(1...4, id: \.self) { day in
                    VStack {
                        Circle()
                            .fill(day <= currentDay.rawValue ? Theme.accentCyan : Theme.textSecondary.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("\(day)")
                                    .font(.caption2)
                                    .foregroundColor(Theme.textPrimary)
                            )
                        Text("D\(day)")
                            .font(.caption2)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(Theme.cardBG)
        .cornerRadius(12)
    }
}

#Preview {
    CycleProgressView(currentDay: .day2)
}
