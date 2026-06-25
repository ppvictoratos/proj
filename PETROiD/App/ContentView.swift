import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Collection", systemImage: "circle.hexagongrid.fill")
                }
            BattleView()
                .tabItem {
                    Label("Battle", systemImage: "bolt.fill")
                }
        }
        .tint(Color("AccentGreen"))
    }
}
