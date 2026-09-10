import SwiftUI

@main
struct EntrakeiaMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .background(EntrakeiaPalette.bg)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
