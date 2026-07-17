import SwiftUI

struct ParkCanvasView: View {
    let scene: ParkScene
    @Binding var imperial: Bool
    let onSwitchPark: () -> Void

    enum Highlight { case cold, warm }

    @State private var rotation = 0.0            // radians
    @State private var baseRotation = 0.0
    @State private var zoom = 1.0
    @State private var baseZoom = 1.0
    @State private var pan = SIMD2<Double>(0, 0) // world meters
    @State private var dragStart: SIMD2<Double>?
    @State private var topDown = false
    @State private var selection: Int?
    @State private var highlight: Highlight?

    private let tilt = 0.62
    private let extrude = 3.0
    private let levelHeights: [Double] = [14, 30, 46]

    // MARK: Projection

    private func fitScale(_ size: CGSize) -> Double {
        let xs = scene.rings[0].map(\.x), ys = scene.rings[0].map(\.y)
        let w = (xs.max() ?? 1) - (xs.min() ?? 0)
        let h = (ys.max() ?? 1) - (ys.min() ?? 0)
        return min(size.width / (w * 1.25), size.height / (h * 1.5)) * zoom
    }

    private func project(_ x: Double, _ y: Double, _ z: Double,
                         size: CGSize) -> (point: CGPoint, depth: Double) {
        let s = fitScale(size)
        let rx = x * cos(rotation) - y * sin(rotation)
        let ry = x * sin(rotation) + y * cos(rotation)
        let t = topDown ? 1.0 : tilt
        let lift = (1 - t * t).squareRoot()
        return (CGPoint(x: size.width / 2 + (rx + pan.x) * s,
                        y: size.height / 2 - ((ry + pan.y) * t + z * lift) * s),
                ry)
    }

    private func path(_ ring: [SIMD2<Double>], z: Double, size: CGSize) -> Path {
        var p = Path()
        for (i, v) in ring.enumerated() {
            let pt = project(v.x, v.y, z, size: size).point
            i == 0 ? p.move(to: pt) : p.addLine(to: pt)
        }
        p.closeSubpath()
        return p
    }

    private func line(_ pts: [SIMD2<Double>], z: Double, size: CGSize) -> Path {
        var p = Path()
        for (i, v) in pts.enumerated() {
            let pt = project(v.x, v.y, z, size: size).point
            i == 0 ? p.move(to: pt) : p.addLine(to: pt)
        }
        return p
    }

    // MARK: Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in
                        drawScene(ctx: &ctx, size: size, time: t)
                    }
                }
                .contentShape(Rectangle())
                .gesture(tapGesture(geo.size))
                .gesture(dragGesture(geo.size)
                    .simultaneously(with: magnifyGesture)
                    .simultaneously(with: rotateGesture))

                hud
            }
        }
        .background(
            LinearGradient(colors: [Color(red: 0.87, green: 0.94, blue: 0.98),
                                    Color(red: 0.92, green: 0.95, blue: 0.89),
                                    Color(red: 0.86, green: 0.92, blue: 0.82)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
    }

    // MARK: Drawing

    private func drawScene(ctx: inout GraphicsContext, size: CGSize, time: Double) {
        // ground grid
        var grid = Path()
        for i in -8...8 {
            let d = Double(i) * 100
            grid.move(to: project(d, -800, 0, size: size).point)
            grid.addLine(to: project(d, 800, 0, size: size).point)
            grid.move(to: project(-800, d, 0, size: size).point)
            grid.addLine(to: project(800, d, 0, size: size).point)
        }
        ctx.stroke(grid, with: .color(.black.opacity(0.05)), lineWidth: 1)

        // park slab
        for ring in scene.rings {
            ctx.fill(path(ring, z: 0, size: size), with: .color(Color(red: 0.62, green: 0.73, blue: 0.55)))
        }
        for ring in scene.rings {
            let top = path(ring, z: extrude, size: size)
            ctx.fill(top, with: .color(Color(red: 0.71, green: 0.83, blue: 0.63)))
            ctx.stroke(top, with: .color(Color(red: 0.50, green: 0.63, blue: 0.42)), lineWidth: 1.5)
        }

        let f = scene.features
        for r in f.greens { ctx.fill(path(r, z: extrude, size: size), with: .color(Color(red: 0.66, green: 0.80, blue: 0.56))) }
        for r in f.pitches { ctx.fill(path(r, z: extrude, size: size), with: .color(Color(red: 0.79, green: 0.86, blue: 0.62))) }
        for r in f.water { ctx.fill(path(r, z: extrude, size: size), with: .color(Color(red: 0.56, green: 0.74, blue: 0.85))) }
        for r in f.buildings {
            let p = path(r, z: extrude, size: size)
            ctx.fill(p, with: .color(Color(red: 0.85, green: 0.80, blue: 0.72)))
            ctx.stroke(p, with: .color(Color(red: 0.75, green: 0.68, blue: 0.56)), lineWidth: 1)
        }
        for r in f.paths {
            ctx.stroke(line(r, z: extrude, size: size),
                       with: .color(.white.opacity(0.85)),
                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        }
        for r in f.woods { ctx.fill(path(r, z: extrude, size: size), with: .color(Color(red: 0.29, green: 0.49, blue: 0.25).opacity(0.35))) }

        // depth-sorted billboards: trees and markers
        var items: [(depth: Double, draw: (inout GraphicsContext) -> Void)] = []
        for tree in f.trees where Geo.pointInPolygon(tree, scene.rings[0]) {
            items.append((project(tree.x, tree.y, 0, size: size).depth,
                          { drawTree(ctx: &$0, at: tree, size: size) }))
        }
        for spot in scene.spots {
            items.append((project(spot.x, spot.y, 0, size: size).depth,
                          { drawMarker(ctx: &$0, spot: spot, size: size, time: time) }))
        }
        for item in items.sorted(by: { $0.depth > $1.depth }) {
            item.draw(&ctx)
        }
    }

    private func drawTree(ctx: inout GraphicsContext, at p: SIMD2<Double>, size: CGSize) {
        let base = project(p.x, p.y, extrude, size: size).point
        let top = project(p.x, p.y, 9, size: size).point
        let r = max(2.5, 3.2 * fitScale(size))
        var trunk = Path()
        trunk.move(to: base); trunk.addLine(to: top)
        ctx.stroke(trunk, with: .color(Color(red: 0.48, green: 0.36, blue: 0.24)),
                   lineWidth: max(1, 0.8 * fitScale(size)))
        let canopy = Path(ellipseIn: CGRect(x: top.x - r, y: top.y - r, width: 2 * r, height: 2 * r))
        ctx.fill(canopy, with: .color(Color(red: 0.29, green: 0.49, blue: 0.25)))
    }

    private func drawMarker(ctx: inout GraphicsContext, spot: Spot, size: CGSize, time: Double) {
        let isSelected = selection == spot.id
        let isCold = highlight == .cold && spot.id == coldestID
        let isWarm = highlight == .warm && spot.id == warmestID
        let base = project(spot.x, spot.y, extrude, size: size).point

        let disc = Path(ellipseIn: CGRect(x: base.x - 14, y: base.y - 7, width: 28, height: 14))
        let discColor: Color = isCold ? .blue.opacity(0.3) : isWarm ? .red.opacity(0.3) : .black.opacity(0.14)
        ctx.fill(disc, with: .color(discColor))

        if isCold || isWarm || isSelected {
            let pulse = 1 + 0.18 * sin(time * 3.6)
            let ring = Path(ellipseIn: CGRect(x: base.x - 20 * pulse, y: base.y - 10 * pulse,
                                              width: 40 * pulse, height: 20 * pulse))
            ctx.stroke(ring, with: .color(isCold ? .blue : isWarm ? .red : .primary), lineWidth: 2.5)
        }

        var pole = Path()
        pole.move(to: base)
        pole.addLine(to: project(spot.x, spot.y, levelHeights[2] + 6, size: size).point)
        ctx.stroke(pole, with: .color(.black.opacity(0.35)), lineWidth: 1.5)

        for (i, level) in spot.weather.levels.enumerated() {
            drawArrow(ctx: &ctx, spot: spot, level: level, z: levelHeights[i], size: size, time: time)
        }

        // feels-like tag
        let tagAnchor = project(spot.x, spot.y, levelHeights[2] + 14, size: size).point
        let prefix = isCold ? "❄️ " : isWarm ? "🔥 " : ""
        let label = ctx.resolve(Text(prefix + formatTemp(spot.feels))
            .font(.caption.bold())
            .foregroundStyle(isSelected ? Color.white : .primary))
        let measured = label.measure(in: CGSize(width: 200, height: 40))
        let pill = CGRect(x: tagAnchor.x - measured.width / 2 - 6, y: tagAnchor.y - 20,
                          width: measured.width + 12, height: measured.height + 6)
        ctx.fill(Path(roundedRect: pill, cornerRadius: 8),
                 with: .color(isSelected ? Color.primary : .white.opacity(0.9)))
        ctx.draw(label, at: CGPoint(x: tagAnchor.x, y: pill.midY))
    }

    private func drawArrow(ctx: inout GraphicsContext, spot: Spot, level: WindLevel,
                           z: Double, size: CGSize, time: Double) {
        // meteorological direction = where wind comes FROM; arrow points downwind
        let toRad = (level.direction + 180).truncatingRemainder(dividingBy: 360) * .pi / 180
        let length = min(42, max(10, 8 + level.speed * 1.1))
        let drift = (time / 0.9).truncatingRemainder(dividingBy: 1) * 6 - 3
        let ux = sin(toRad), uy = cos(toRad)
        let a = project(spot.x - ux * (length / 2 - drift), spot.y - uy * (length / 2 - drift), z, size: size).point
        let b = project(spot.x + ux * (length / 2 + drift), spot.y + uy * (length / 2 + drift), z, size: size).point

        let color = temperatureColor(level.temperature)
        let width = min(8, max(2.5, 2.2 + level.speed * 0.12))
        var shaft = Path()
        shaft.move(to: a); shaft.addLine(to: b)
        ctx.stroke(shaft, with: .color(.white.opacity(0.85)),
                   style: StrokeStyle(lineWidth: width + 3, lineCap: .round))
        ctx.stroke(shaft, with: .color(color),
                   style: StrokeStyle(lineWidth: width, lineCap: .round))

        let angle = atan2(b.y - a.y, b.x - a.x)
        let headSize = width * 2.4
        var head = Path()
        head.move(to: CGPoint(x: b.x + cos(angle) * headSize * 1.6, y: b.y + sin(angle) * headSize * 1.6))
        head.addLine(to: CGPoint(x: b.x + cos(angle + 2.5) * headSize, y: b.y + sin(angle + 2.5) * headSize))
        head.addLine(to: CGPoint(x: b.x + cos(angle - 2.5) * headSize, y: b.y + sin(angle - 2.5) * headSize))
        head.closeSubpath()
        ctx.fill(head, with: .color(color))
        ctx.stroke(head, with: .color(.white.opacity(0.85)), lineWidth: 1.5)
    }

    // MARK: Gestures

    private func dragGesture(_ size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                if dragStart == nil { dragStart = pan }
                guard let start = dragStart else { return }
                let s = fitScale(size)
                let t = topDown ? 1.0 : tilt
                let wx = value.translation.width / s
                let wy = -value.translation.height / (s * t)
                let cr = cos(-rotation), sr = sin(-rotation)
                pan = start + SIMD2(wx * cr - wy * sr, wx * sr + wy * cr)
            }
            .onEnded { _ in dragStart = nil }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { zoom = min(8, max(0.3, baseZoom * $0)) }
            .onEnded { _ in baseZoom = zoom }
    }

    private var rotateGesture: some Gesture {
        RotationGesture()
            .onChanged { rotation = baseRotation + $0.radians }
            .onEnded { _ in baseRotation = rotation }
    }

    private func tapGesture(_ size: CGSize) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                var best: Int?
                var bestDistance = 48.0
                for spot in scene.spots {
                    for z in [extrude] + levelHeights {
                        let p = project(spot.x, spot.y, z, size: size).point
                        let d = hypot(p.x - value.location.x, p.y - value.location.y)
                        if d < bestDistance { bestDistance = d; best = spot.id }
                    }
                }
                selection = (selection == best) ? nil : best
            }
    }

    // MARK: HUD

    private var coldestID: Int? { scene.spots.min(by: { $0.feels < $1.feels })?.id }
    private var warmestID: Int? { scene.spots.max(by: { $0.feels < $1.feels })?.id }

    private var hud: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(scene.park.name).font(.headline)
                    Text("drag to pan · pinch to zoom · twist to rotate")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()

                if let first = scene.spots.first {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatTemp(first.weather.temperature)).font(.title3.bold())
                        Text("\(formatSpeed(first.weather.levels[0].speed)) \(compass(first.weather.levels[0].direction))")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(12)

            Spacer()

            if let sel = selection, let spot = scene.spots.first(where: { $0.id == sel }) {
                detailCard(spot)
            }

            HStack(spacing: 10) {
                Button {
                    highlight = highlight == .cold ? nil : .cold
                    selection = highlight == .cold ? coldestID : nil
                } label: { Label("Coldest", systemImage: "snowflake") }
                    .tint(highlight == .cold ? .blue : nil)

                Button {
                    highlight = highlight == .warm ? nil : .warm
                    selection = highlight == .warm ? warmestID : nil
                } label: { Label("Warmest", systemImage: "flame") }
                    .tint(highlight == .warm ? .red : nil)

                Button { topDown.toggle() } label: {
                    Label(topDown ? "3D" : "2D", systemImage: topDown ? "mountain.2" : "map")
                }

                Button { imperial.toggle() } label: { Text(imperial ? "°F" : "°C") }

                Button(action: onSwitchPark) { Label("Park", systemImage: "mappin") }
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .background(.regularMaterial, in: Capsule())
            .padding(.bottom, 14)
        }
    }

    private func detailCard(_ spot: Spot) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Spot \(spot.id + 1) of \(scene.spots.count)").font(.headline)
            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 3) {
                ForEach(spot.weather.levels, id: \.height) { level in
                    GridRow {
                        Text("\(level.height) m").bold()
                        Text("\(formatSpeed(level.speed)) \(compass(level.direction))")
                            .foregroundStyle(.secondary)
                        Text(formatTemp(level.temperature))
                            .bold()
                            .foregroundStyle(temperatureColor(level.temperature))
                    }
                }
            }
            Text("Feels like **\(formatTemp(spot.feels))** here — \(spot.descriptor)")
                .font(.subheadline)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .padding(.bottom, 8)
        .onTapGesture { selection = nil }
    }

    // MARK: Formatting

    private func formatTemp(_ celsius: Double) -> String {
        imperial ? "\(Int((celsius * 9 / 5 + 32).rounded()))°F" : "\(Int(celsius.rounded()))°C"
    }

    private func formatSpeed(_ kmh: Double) -> String {
        imperial ? "\(Int((kmh * 0.621371).rounded())) mph" : "\(Int(kmh.rounded())) km/h"
    }

    private func compass(_ direction: Double) -> String {
        let names = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return names[Int(((direction.truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360) / 45).rounded()) % 8]
    }

    private func temperatureColor(_ t: Double) -> Color {
        let stops: [(Double, (Double, Double, Double))] = [
            (-10, (30, 58, 138)), (0, (59, 130, 246)), (10, (34, 211, 238)),
            (18, (163, 230, 53)), (24, (250, 204, 21)), (30, (251, 146, 60)), (38, (239, 68, 68)),
        ]
        if t <= stops[0].0 { return rgb(stops[0].1) }
        for i in 1..<stops.count where t <= stops[i].0 {
            let (t0, c0) = stops[i - 1], (t1, c1) = stops[i]
            let f = (t - t0) / (t1 - t0)
            return rgb((c0.0 + (c1.0 - c0.0) * f, c0.1 + (c1.1 - c0.1) * f, c0.2 + (c1.2 - c0.2) * f))
        }
        return rgb(stops[stops.count - 1].1)
    }

    private func rgb(_ c: (Double, Double, Double)) -> Color {
        Color(red: c.0 / 255, green: c.1 / 255, blue: c.2 / 255)
    }
}
