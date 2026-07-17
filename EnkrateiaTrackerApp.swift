import SwiftUI
import SwiftData

@main
struct EnkrateiaTrackerApp: App {
    let container = ModelContainerProvider.shared.container

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
                .preferredColorScheme(.dark)
                .onAppear {
                    NotificationService.shared.requestNotificationPermission()
                    let context = ModelContext(container)
                    TetradCycleService.shared.setup(with: context)
                }
        }
    }
}
