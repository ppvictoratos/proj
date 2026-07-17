import SwiftUI

struct TimelineIndicator: View {
    let progress: Double  // 0.0 to 1.0 within current tetrad
    let size: CGFloat = 60

    // Black marble + stone grey palette
    private let marbleBlack = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let stoneGrey = Color(red: 0.17, green: 0.17, blue: 0.17)
    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)

    var body: some View {
        ZStack {
            // Rotating square (diamond orientation)
            RoundedRectangle(cornerRadius: 4)
                .stroke(accentCyan, lineWidth: 2)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))

            // Animated gradient accent on current corner
            Canvas { context in
                let angle = (progress * 360).truncatingRemainder(dividingBy: 360)
                var path = Path()
                path.addArc(center: .init(x: size/2, y: 0),
                           radius: 3, startAngle: .degrees(0), endAngle: .degrees(180),
                           clockwise: false)
                context.stroke(path, with: .color(accentCyan), lineWidth: 2)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.04, green: 0.04, blue: 0.04).ignoresSafeArea()
        TimelineIndicator(progress: 0.25)
    }
}
