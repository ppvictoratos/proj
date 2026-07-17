import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) var modelContext
    @State private var activeTab: String = "dashboard"

    private let marbleBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)

    var body: some View {
        ZStack {
            Group {
                if activeTab == "dashboard" {
                    DashboardView(modelContext: modelContext)
                } else if activeTab == "exercises" {
                    ExerciseListView(viewModel: TetradCycleViewModel(modelContext: modelContext))
                } else {
                    TetradsView()
                }
            }

            VStack {
                Spacer()

                HStack(spacing: 20) {
                    Button(action: { activeTab = "exercises" }) {
                        Text("EXERCISES")
                            .font(.system(weight: .semibold, size: 14))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(activeTab == "exercises" ? accentCyan : accentCyan.opacity(0.2))
                            .foregroundColor(activeTab == "exercises" ? .black : accentCyan)
                            .cornerRadius(8)
                    }

                    Button(action: { activeTab = "tetrads" }) {
                        Text("TETRADS")
                            .font(.system(weight: .semibold, size: 14))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(activeTab == "tetrads" ? accentCyan : accentCyan.opacity(0.2))
                            .foregroundColor(activeTab == "tetrads" ? .black : accentCyan)
                            .cornerRadius(8)
                    }
                }
                .padding(16)
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(ModelContainerProvider.shared.container)
}
