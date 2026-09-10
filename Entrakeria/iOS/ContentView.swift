import SwiftUI

struct ContentView: View {
    @State private var selectedDay: Int = 0
    @State private var activeView: String?

    var body: some View {
        if activeView == "stretch" {
            StretchListView(activeView: $activeView)
        } else if activeView == "wim_hof" {
            WimHofView(activeView: $activeView)
        } else if activeView == "exercise" {
            ExerciseListView(activeView: $activeView)
        } else if activeView == "walk" {
            WalkLogView(activeView: $activeView)
        } else {
            tetradView
        }
    }

    var tetradView: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("ΕΝΤΡΑΚΕΡΙΑ")
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(3)
                    .foregroundStyle(EntrakeiaPalette.accent)

                Canvas { ctx, size in
                    let centerY = size.height / 2
                    let path = TetradGeometry.ribbonPath(days: 4, unit: 40, centerY: centerY)
                    ctx.stroke(path, with: .color(EntrakeiaPalette.line), lineWidth: 1.5)
                    let current = TetradGeometry.vertices(forDay: selectedDay, unit: 40, centerY: centerY)
                    for p in current {
                        let dot = Path(ellipseIn: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8))
                        ctx.fill(dot, with: .color(EntrakeiaPalette.blue))
                    }
                }
                .frame(height: 80)

                Text("DAY \(selectedDay + 1)")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(EntrakeiaPalette.line)

                ZStack {
                    Diamond()
                        .stroke(EntrakeiaPalette.line, lineWidth: 1.5)
                        .frame(width: 160, height: 160)

                    VStack(spacing: 100) {
                        HStack(spacing: 100) {
                            SmallButton(title: "STRETCH", action: { activeView = "stretch" })
                            SmallButton(title: "WIM", action: { activeView = "wim_hof" })
                        }
                        HStack(spacing: 100) {
                            SmallButton(title: "WALK", action: { activeView = "walk" })
                            SmallButton(title: "EXER", action: { activeView = "exercise" })
                        }
                    }
                    .frame(width: 160, height: 160)
                }

                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { day in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDay = day
                            }
                        } label: {
                            Text("D\(day + 1)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(selectedDay == day ? EntrakeiaPalette.bg : EntrakeiaPalette.text)
                                .frame(maxWidth: .infinity)
                                .frame(height: 32)
                                .background(selectedDay == day ? EntrakeiaPalette.blue : EntrakeiaPalette.card)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(12)
        }
    }
}

struct SmallButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: "figure.strengthtraining")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(EntrakeiaPalette.blue)

                Text(title)
                    .font(.system(size: 8, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(EntrakeiaPalette.text)
            }
            .frame(width: 50, height: 50)
            .background(RoundedRectangle(cornerRadius: 4).stroke(EntrakeiaPalette.line, lineWidth: 1))
        }
    }
}

struct Diamond: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.midY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    ContentView()
}
