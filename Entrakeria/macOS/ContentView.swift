import SwiftUI

struct ContentView: View {
    @State private var selectedDay: Int = 0

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()

            VStack(spacing: 40) {
                // Title
                Text("ΕΝΤΡΑΚΕΡΙΑ")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .tracking(4)
                    .foregroundStyle(EntrakeiaPalette.brown)

                // Tetrad ribbon
                Canvas { ctx, size in
                    let centerY = size.height / 2
                    let path = TetradGeometry.ribbonPath(days: 4, unit: 80, centerY: centerY)
                    ctx.stroke(path, with: .color(EntrakeiaPalette.line), lineWidth: 2)

                    // Highlight current day
                    let current = TetradGeometry.vertices(forDay: selectedDay, unit: 80, centerY: centerY)
                    for p in current {
                        let dot = Path(ellipseIn: CGRect(x: p.x - 6, y: p.y - 6, width: 12, height: 12))
                        ctx.fill(dot, with: .color(EntrakeiaPalette.blue))
                    }
                }
                .frame(height: 140)
                .padding(.horizontal, 40)

                // Day label
                Text("DAY \(selectedDay + 1) OF 4")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .tracking(2)
                    .foregroundStyle(EntrakeiaPalette.brown)

                // Four-corner exercise grid
                ZStack {
                    // Diamond outline
                    Diamond()
                        .stroke(EntrakeiaPalette.line, lineWidth: 2)
                        .frame(width: 280, height: 280)

                    VStack(spacing: 200) {
                        HStack(spacing: 200) {
                            ExerciseButton(title: "STRETCH", isActive: true)
                            ExerciseButton(title: "WIM HOF", isActive: false)
                        }
                        HStack(spacing: 200) {
                            ExerciseButton(title: "WALK", isActive: false)
                            ExerciseButton(title: "EXERCISE", isActive: false)
                        }
                    }
                    .frame(width: 280, height: 280)
                }
                .padding(40)

                // Navigation
                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { day in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedDay = day
                            }
                        } label: {
                            Text("D\(day + 1)")
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundStyle(selectedDay == day ? .white : EntrakeiaPalette.brown)
                                .frame(width: 50, height: 40)
                                .background(selectedDay == day ? EntrakeiaPalette.brown : EntrakeiaPalette.bg.opacity(0.5))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(20)

                Spacer()
            }
            .padding(40)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct ExerciseButton: View {
    let title: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.strengthtraining")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(isActive ? EntrakeiaPalette.blue : EntrakeiaPalette.line.opacity(0.3))

            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .default))
                .tracking(1)
                .foregroundStyle(isActive ? EntrakeiaPalette.blue : EntrakeiaPalette.line.opacity(0.3))
        }
        .frame(width: 70, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? EntrakeiaPalette.blue : EntrakeiaPalette.line.opacity(0.2), lineWidth: 1.5)
        )
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
