import SwiftUI

struct TetradRibbonView: View {
    let cycleDays: Int
    @Binding var scrubProgress: CGFloat
    let unit: CGFloat = 60

    private var width: CGFloat { unit * CGFloat(cycleDays) * 2 }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Canvas { ctx, size in
                let centerY = size.height / 2
                let path = TetradGeometry.ribbonPath(days: cycleDays, unit: unit, centerY: centerY)
                ctx.stroke(path, with: .color(EnkrateiaPalette.line), lineWidth: 1.5)

                let p = TetradGeometry.point(atProgress: scrubProgress, days: cycleDays,
                                             unit: unit, centerY: centerY)
                let dotRect = CGRect(x: p.x - 6, y: p.y - 6, width: 12, height: 12)
                ctx.fill(Path(ellipseIn: dotRect),
                         with: .radialGradient(Gradient(colors: [EnkrateiaPalette.gold, .clear]),
                                               center: p, startRadius: 0, endRadius: 12))
            }
            .frame(width: width, height: 160)
            .contentShape(Rectangle())
            // minimumDistance 0 so a tap scrubs too; the horizontal scroll still wins on a swipe.
            .gesture(DragGesture(minimumDistance: 0).onChanged { g in
                scrubProgress = max(0, min(1, g.location.x / width))
            })
        }
    }
}

#Preview {
    ZStack {
        EnkrateiaPalette.bg.ignoresSafeArea()
        TetradRibbonView(cycleDays: 4, scrubProgress: .constant(0.3))
    }
}
