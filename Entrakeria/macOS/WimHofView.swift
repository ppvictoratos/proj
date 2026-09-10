import SwiftUI

struct WimHofView: View {
    @Binding var activeView: String?
    @State private var isBreathing = false
    @State private var breathCount = 0
    @State private var phase = "in"
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()

            VStack(spacing: 40) {
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
                }
                .padding(20)

                Text("WIM HOF")
                    .font(.system(size: 28, weight: .semibold))
                    .tracking(4)
                    .foregroundStyle(EntrakeiaPalette.accent)

                ZStack {
                    Circle()
                        .stroke(EntrakeiaPalette.line, lineWidth: 2)
                        .frame(width: 200, height: 200)

                    Circle()
                        .fill(EntrakeiaPalette.blue.opacity(0.3))
                        .frame(width: isBreathing ? 180 : 160, height: isBreathing ? 180 : 160)
                        .animation(.easeInOut(duration: phase == "in" ? 4 : 6), value: isBreathing)

                    VStack(spacing: 20) {
                        Text(phase.uppercased())
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(EntrakeiaPalette.text)
                        Text("\(breathCount)")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(EntrakeiaPalette.accent)
                    }
                }

                Button(action: toggleBreathing) {
                    Text(isBreathing ? "STOP" : "START")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(2)
                        .frame(width: 150, height: 50)
                        .background(isBreathing ? EntrakeiaPalette.line : EntrakeiaPalette.blue)
                        .foregroundStyle(EntrakeiaPalette.bg)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(40)
        }
        .frame(minWidth: 800, minHeight: 1000)
    }

    func toggleBreathing() {
        isBreathing.toggle()
        if isBreathing {
            breathCount = 0
            startBreathingCycle()
        } else {
            timer?.invalidate()
        }
    }

    func startBreathingCycle() {
        phase = "in"
        var elapsed = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsed += 0.1
            if phase == "in" && elapsed >= 4 {
                phase = "out"
                elapsed = 0
                breathCount += 1
            } else if phase == "out" && elapsed >= 6 {
                phase = "in"
                elapsed = 0
                if breathCount >= 40 {
                    isBreathing = false
                    timer?.invalidate()
                }
            }
        }
    }
}

#Preview {
    WimHofView(activeView: .constant("wim_hof"))
}
