import SwiftUI
import SwiftData

@main
struct PETROiDApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Rock.self)

        #if os(macOS)
        Window("Rock PC", id: "rock-pc") {
            RockPCView()
        }
        .modelContainer(for: Rock.self)
        #endif
    }
}
