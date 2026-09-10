import SwiftUI

struct WimHofView: View {
    @Binding var activeView: String?
    @State private var isBreathing = false
    @State private var breathCount = 0

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Button(action: { activeView = nil }) {
                        Text("← Back")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(EntrakeiaPalette.blue)
                    }
                    Spacer()
                }
                .padding(12)

                Text("WIM HOF")
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(EntrakeiaPalette.accent)

                ZStack {
                    Circle()
                        .stroke(EntrakeiaPalette.line, lineWidth: 2)
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(EntrakeiaPalette.blue.opacity(0.2))
                        .frame(width: isBreathing ? 110 : 100, height: isBreathing ? 110 : 100)
                        .animation(.easeInOut(duration: 4), value: isBreathing)

                    Text("\(breathCount)")
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(EntrakeiaPalette.accent)
                }

                Button(action: { isBreathing.toggle() }) {
                    Text(isBreathing ? "STOP" : "START")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(isBreathing ? EntrakeiaPalette.line : EntrakeiaPalette.blue)
                        .foregroundStyle(EntrakeiaPalette.bg)
                        .cornerRadius(6)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(12)
        }
    }
}

#Preview {
    WimHofView(activeView: .constant(nil))
}
