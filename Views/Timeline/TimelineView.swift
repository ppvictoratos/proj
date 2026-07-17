import SwiftUI
import SwiftData

struct TimelineView: View {
    @ObservedObject var viewModel: TetradCycleViewModel
    @State private var scrollPosition: UUID?
    @Query(sort: [SortDescriptor(\.date, order: .reverse)]) var sessions: [WorkoutSession]

    private let marbleBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)
    private let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.63)

    var body: some View {
        VStack(spacing: 16) {
            Text("ENKRATEIA")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(textLight)

            // Timeline scrubber
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                            VStack(spacing: 4) {
                                TimelineIndicator(progress: Double(index) / Double(max(sessions.count, 1)))
                                    .id(session.id)

                                Text(session.tetradDay.name)
                                    .font(.caption)
                                    .foregroundColor(textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .onAppear {
                    if let firstSession = sessions.first {
                        proxy.scrollTo(firstSession.id, anchor: .center)
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(marbleBlack.ignoresSafeArea())
    }
}

#Preview {
    TimelineView(viewModel: TetradCycleViewModel(modelContext: .preview))
        .modelContainer(ModelContainerProvider.shared.container)
}
