import SwiftUI

struct StretchListView: View {
    @Binding var activeView: String?

    let stretches = [
        ("Pelvic Tilts", "29 slow reps, flatback"),
        ("Glute Bridges", "2x12, 2 sec squeeze"),
        ("Ham Bridges", "2x12, 2 sec squeeze"),
        ("Clamshells", "2x20 each side"),
        ("Lateral Leg Lifts", "2x10"),
        ("Child's Pose", "60 sec"),
        ("Cat Cows", "3x10"),
        ("Pigeon", "60 sec each side"),
        ("90/90 Hip Stretch", "60 sec each side"),
        ("Dead Bug", "3x8 each side"),
        ("Curl Up L/R", "2x10 each"),
        ("Bear Planks w/ KB Drag", "")
    ]

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { activeView = nil }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(EntrakeiaPalette.blue)
                    }
                    Spacer()
                    Text("STRETCHES")
                        .font(.system(size: 18, weight: .semibold))
                        .tracking(3)
                        .foregroundStyle(EntrakeiaPalette.accent)
                    Spacer()
                    Color.clear.frame(width: 50)
                }
                .padding(20)
                .borderBottom(height: 1, color: EntrakeiaPalette.line)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(stretches, id: \.0) { name, reps in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(EntrakeiaPalette.text)
                                if !reps.isEmpty {
                                    Text(reps)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundStyle(EntrakeiaPalette.line)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .borderBottom(height: 1, color: EntrakeiaPalette.card)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 1000)
    }
}

#Preview {
    StretchListView(activeView: .constant("stretch"))
}
