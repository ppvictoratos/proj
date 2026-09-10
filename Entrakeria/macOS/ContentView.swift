import SwiftUI

struct ContentView: View {
    @State private var selectedDay: Int = 0
    @State private var activeView: String? = nil

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

            VStack(spacing: 40) {
                Text("ΕΝΤΡΑΚΕΡΙΑ")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .tracking(4)
                    .foregroundStyle(EntrakeiaPalette.accent)

                Canvas { ctx, size in
                    let centerY = size.height / 2
                    let path = TetradGeometry.ribbonPath(days: 4, unit: 80, centerY: centerY)
                    ctx.stroke(path, with: .color(EntrakeiaPalette.line), lineWidth: 2)

                    let current = TetradGeometry.vertices(forDay: selectedDay, unit: 80, centerY: centerY)
                    for p in current {
                        let dot = Path(ellipseIn: CGRect(x: p.x - 6, y: p.y - 6, width: 12, height: 12))
                        ctx.fill(dot, with: .color(EntrakeiaPalette.blue))
                    }
                }
                .frame(height: 140)
                .padding(.horizontal, 40)

                Text("DAY \(selectedDay + 1) OF 4")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .tracking(2)
                    .foregroundStyle(EntrakeiaPalette.line)

                ZStack {
                    Diamond()
                        .stroke(EntrakeiaPalette.line, lineWidth: 2)
                        .frame(width: 280, height: 280)

                    VStack(spacing: 200) {
                        HStack(spacing: 200) {
                            ExerciseButton(title: "STRETCH", isActive: true, action: { activeView = "stretch" })
                            ExerciseButton(title: "WIM HOF", isActive: false, action: { activeView = "wim_hof" })
                        }
                        HStack(spacing: 200) {
                            ExerciseButton(title: "WALK", isActive: false, action: { activeView = "walk" })
                            ExerciseButton(title: "EXERCISE", isActive: false, action: { activeView = "exercise" })
                        }
                    }
                    .frame(width: 280, height: 280)
                }
                .padding(40)

                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { day in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedDay = day
                            }
                        } label: {
                            Text("D\(day + 1)")
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundStyle(selectedDay == day ? EntrakeiaPalette.bg : EntrakeiaPalette.text)
                                .frame(width: 50, height: 40)
                                .background(selectedDay == day ? EntrakeiaPalette.blue : EntrakeiaPalette.card)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(20)

                Spacer()
            }
            .padding(40)
        }
        .frame(minWidth: 800, minHeight: 1000)
    }
}

struct ExerciseButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "figure.strengthtraining")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(isActive ? EntrakeiaPalette.blue : EntrakeiaPalette.line)

                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .tracking(1)
                    .foregroundStyle(isActive ? EntrakeiaPalette.text : EntrakeiaPalette.line)
            }
            .frame(width: 70, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? EntrakeiaPalette.blue : EntrakeiaPalette.line, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
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
