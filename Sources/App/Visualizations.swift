import SwiftUI

struct BeatDrivenView: View {
    let audioMetrics: AudioMetrics
    @State private var pipes: [Pipe] = []
    @State private var displayLink: CADisplayLink?

    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 0),
                with: .color(ColorPalette.darkBackground)
            )

            for pipe in pipes {
                drawPipe(context, pipe: pipe, size: size)
            }
        }
        .background(ColorPalette.darkBackground)
        .onAppear {
            startAnimation()
        }
        .onChange(of: audioMetrics) { _ in
            updatePipes()
        }
    }

    private func drawPipe(_ context: inout GraphicsContext, pipe: Pipe, size: CGSize) {
        let opacity = 1.0 - min(pipe.age / 2.0, 1.0)

        var path = Path()
        let endX = pipe.x + pipe.length * cos(pipe.angle)
        let endY = pipe.y + pipe.length * sin(pipe.angle)

        path.move(to: CGPoint(x: pipe.x, y: pipe.y))
        path.addLine(to: CGPoint(x: endX, y: endY))

        let glowColor = ColorPalette.primaryGlow.opacity(opacity * ColorPalette.glowIntensity)

        context.stroke(
            path,
            with: .color(glowColor),
            lineWidth: pipe.thickness
        )

        context.stroke(
            path,
            with: .color(glowColor.opacity(0.3)),
            lineWidth: pipe.thickness * 2
        )
    }

    private func updatePipes() {
        let now = audioMetrics.timestamp

        if audioMetrics.beat {
            let newPipe = Pipe(
                x: CGFloat.random(in: 100...700),
                y: CGFloat.random(in: 100...500),
                angle: Double.random(in: 0...(2 * .pi)),
                length: CGFloat(audioMetrics.energy) * 100 + 50,
                thickness: CGFloat(audioMetrics.energy) * 8 + 2,
                age: 0,
                hue: Double.random(in: 0...1)
            )
            pipes.append(newPipe)
        }

        for i in 0..<pipes.count {
            pipes[i].age = now - pipes[i].age
            pipes[i].length = CGFloat(audioMetrics.energy) * 100 + 50
            pipes[i].thickness = CGFloat(audioMetrics.energy) * 8 + 2
        }

        pipes.removeAll { $0.age > 2.0 }
    }

    private func startAnimation() {
        displayLink = CADisplayLink(target: PipeAnimationTarget(), selector: #selector(PipeAnimationTarget.tick))
        displayLink?.add(to: .main, forMode: .common)
    }
}

private class PipeAnimationTarget: NSObject {
    @objc func tick() { }
}

struct FrequencyBandView: View {
    let audioMetrics: AudioMetrics

    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 0),
                with: .color(ColorPalette.darkBackground)
            )

            let bandCount = audioMetrics.frequencies.count
            let bandWidth = size.width / CGFloat(bandCount)

            for (index, frequency) in audioMetrics.frequencies.enumerated() {
                let x = CGFloat(index) * bandWidth + bandWidth / 2
                let height = frequency * size.height * 0.8
                let y = size.height - height

                let hue = Double(index) / Double(bandCount)
                let color = Color(hue: hue, saturation: 0.8, brightness: 0.9)
                let glowColor = color.opacity(ColorPalette.glowIntensity)

                var path = Path()
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x, y: y))

                context.stroke(path, with: .color(glowColor), lineWidth: bandWidth * 0.7)
                context.stroke(path, with: .color(glowColor.opacity(0.4)), lineWidth: bandWidth * 1.2)
            }
        }
        .background(ColorPalette.darkBackground)
    }
}

struct HybridView: View {
    let audioMetrics: AudioMetrics
    @State private var beatPipes: [Pipe] = []

    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 0),
                with: .color(ColorPalette.darkBackground)
            )

            drawFrequencyBands(context, size: size)

            for pipe in beatPipes {
                drawBeatPipe(context, pipe: pipe)
            }
        }
        .background(ColorPalette.darkBackground)
        .onChange(of: audioMetrics) { _ in
            updateBeatPipes()
        }
    }

    private func drawFrequencyBands(_ context: inout GraphicsContext, size: CGSize) {
        let bandCount = audioMetrics.frequencies.count
        let bandWidth = size.width / CGFloat(bandCount)

        for (index, frequency) in audioMetrics.frequencies.enumerated() {
            let x = CGFloat(index) * bandWidth + bandWidth / 2
            let height = frequency * size.height * 0.5
            let y = size.height - height

            let hue = Double(index) / Double(bandCount)
            let color = Color(hue: hue, saturation: 0.6, brightness: 0.6)

            var path = Path()
            path.move(to: CGPoint(x: x, y: size.height))
            path.addLine(to: CGPoint(x: x, y: y))

            context.stroke(path, with: .color(color.opacity(0.5)), lineWidth: bandWidth * 0.6)
        }
    }

    private func drawBeatPipe(_ context: inout GraphicsContext, pipe: Pipe) {
        let opacity = 1.0 - min(pipe.age / 1.5, 1.0)

        var path = Path()
        let endX = pipe.x + pipe.length * cos(pipe.angle)
        let endY = pipe.y + pipe.length * sin(pipe.angle)

        path.move(to: CGPoint(x: pipe.x, y: pipe.y))
        path.addLine(to: CGPoint(x: endX, y: endY))

        let glowColor = ColorPalette.primaryGlow.opacity(opacity * 0.9)

        context.stroke(path, with: .color(glowColor), lineWidth: pipe.thickness)
        context.stroke(path, with: .color(glowColor.opacity(0.3)), lineWidth: pipe.thickness * 2)
    }

    private func updateBeatPipes() {
        let now = audioMetrics.timestamp

        if audioMetrics.beat {
            let newPipe = Pipe(
                x: CGFloat.random(in: 100...700),
                y: CGFloat.random(in: 100...500),
                angle: Double.random(in: 0...(2 * .pi)),
                length: CGFloat(audioMetrics.energy) * 80 + 40,
                thickness: CGFloat(audioMetrics.energy) * 6 + 1.5,
                age: 0,
                hue: 0
            )
            beatPipes.append(newPipe)
        }

        for i in 0..<beatPipes.count {
            beatPipes[i].age = now - beatPipes[i].age
        }

        beatPipes.removeAll { $0.age > 1.5 }
    }
}
