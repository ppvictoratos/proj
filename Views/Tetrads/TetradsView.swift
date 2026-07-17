import SwiftUI
import SwiftData

struct TetradsView: View {
    @Query(sort: [SortDescriptor(\.date, order: .reverse)]) var sessions: [WorkoutSession]

    private let marbleBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)
    private let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.63)

    var body: some View {
        ZStack {
            marbleBlack.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("TETRADS")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(textLight)

                if sessions.isEmpty {
                    Text("No tetrads logged yet")
                        .foregroundColor(textSecondary)
                        .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(sessions, id: \.id) { session in
                                TetradHistoryRow(session: session)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }
}

#Preview {
    TetradsView()
        .modelContainer(ModelContainerProvider.shared.container)
}
