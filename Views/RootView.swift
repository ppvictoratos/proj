import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) var modelContext

    var body: some View {
        TabView {
            DashboardView(modelContext: modelContext)
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(.cyan)
    }
}

#Preview {
    RootView()
        .modelContainer(ModelContainerProvider.shared.container)
}
