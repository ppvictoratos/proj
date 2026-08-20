import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Today")
                }

            WeeklyPlanView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Weekly")
                }

            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
        }
        .tint(HPTheme.neon)
        .preferredColorScheme(.dark)
    }
}
