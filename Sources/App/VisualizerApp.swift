import SwiftUI

@main
struct VisualizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.default)
        .windowResizability(.automatic)
        .defaultSize(width: 800, height: 600)
    }
}
