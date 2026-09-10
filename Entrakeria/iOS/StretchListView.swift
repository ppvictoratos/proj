import SwiftUI

struct StretchListView: View {
    @Binding var activeView: String?

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: { activeView = nil }) {
                        Text("← Back")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(EntrakeiaPalette.blue)
                    }
                    Spacer()
                }
                .padding(12)

                Text("STRETCHES")
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(EntrakeiaPalette.accent)
                    .padding(12)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(["Pelvic Tilts", "Glute Bridges", "Clamshells", "Cat Cows", "Pigeon", "90/90 Hip", "Dead Bug", "Couch Stretch", "Child's Pose", "Ham Bridges", "Lateral Leg Lifts", "Bear Planks"], id: \.self) { name in
                            HStack {
                                Text(name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(EntrakeiaPalette.text)
                                Spacer()
                            }
                            .padding(12)
                            .borderBottom(height: 0.5, color: EntrakeiaPalette.card)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StretchListView(activeView: .constant(nil))
}
