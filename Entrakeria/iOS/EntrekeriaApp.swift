import SwiftUI
import SwiftData

@main
struct EntrekeriaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [TetradCycle.self, WorkoutSession.self, WorkoutLog.self])
    }
}
