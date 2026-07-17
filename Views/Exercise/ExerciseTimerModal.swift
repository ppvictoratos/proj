import SwiftUI

struct ExerciseTimerModal: View {
    @ObservedObject var viewModel: WorkoutSessionViewModel
    @Environment(\.dismiss) var dismiss

    private let marbleBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let stoneGrey = Color(red: 0.17, green: 0.17, blue: 0.17)
    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)
    private let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.63)

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Rest Timer")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textLight)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(textSecondary)
                }
            }

            if viewModel.timerIsRunning {
                Text(String(format: "%02d:%02d",
                           viewModel.remainingSeconds / 60,
                           viewModel.remainingSeconds % 60))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(accentCyan)
                    .transition(.scale)

                Button(action: viewModel.stopRestTimer) {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            } else {
                Text("Select Rest Duration")
                    .font(.caption)
                    .foregroundColor(textSecondary)

                HStack(spacing: 12) {
                    ForEach([30, 60, 90], id: \.self) { seconds in
                        Button(action: { viewModel.startRestTimer(seconds: seconds) }) {
                            Text("\(seconds)s")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(stoneGrey)
                                .foregroundColor(accentCyan)
                                .cornerRadius(6)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(20)
        .background(marbleBlack)
    }
}

#Preview {
    ExerciseTimerModal(viewModel: WorkoutSessionViewModel(
        session: WorkoutSession(tetradDay: .day1),
        modelContext: .preview
    ))
}
