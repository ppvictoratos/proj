import Foundation
import simd

// MARK: - Domain types

struct Park: Identifiable, Hashable {
    let id: Int
    let osmType: String      // "way" | "relation"
    let name: String
    let kind: String
    let lat: Double
    let lon: Double
    var distance: Double = 0
}

struct WindLevel {
    let height: Int          // meters above ground
    let speed: Double        // km/h
    let direction: Double    // meteorological: where the wind comes FROM
    let temperature: Double  // °C
}

struct SpotWeather {
    let temperature: Double
    let apparent: Double
    let isDay: Bool
    let levels: [WindLevel]  // 10 m, 80 m, 120 m
}

struct Spot: Identifiable {
    let id: Int
    let x: Double            // meters east of park center
    let y: Double            // meters north of park center
    let lat: Double
    let lon: Double
    var weather: SpotWeather
    var feels: Double = 0
    var descriptor: String = "open ground"
}

struct ParkFeatures {
    var trees: [SIMD2<Double>] = []
    var water: [[SIMD2<Double>]] = []
    var woods: [[SIMD2<Double>]] = []
    var greens: [[SIMD2<Double>]] = []
    var pitches: [[SIMD2<Double>]] = []
    var paths: [[SIMD2<Double>]] = []
    var buildings: [[SIMD2<Double>]] = []
}

struct ParkScene {
    let park: Park
    let rings: [[SIMD2<Double>]]   // outer boundary ring(s), meters
    let features: ParkFeatures
    var spots: [Spot]
    let centerLat: Double
    let centerLon: Double
}

// MARK: - Geometry helpers

enum Geo {
    static func haversine(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
        let r = 6_371_000.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2)
              + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * r * asin(sqrt(a))
    }

    /// lat/lon → meters east/north of a reference point.
    static func projector(centerLat: Double, centerLon: Double) -> (Double, Double) -> SIMD2<Double> {
        let kx = 111_320 * cos(centerLat * .pi / 180)
        let ky = 110_574.0
        return { lat, lon in SIMD2((lon - centerLon) * kx, (lat - centerLat) * ky) }
    }

    static func pointInPolygon(_ p: SIMD2<Double>, _ poly: [SIMD2<Double>]) -> Bool {
        var inside = false
        var j = poly.count - 1
        for i in 0..<poly.count {
            let a = poly[i], b = poly[j]
            if (a.y > p.y) != (b.y > p.y),
               p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x {
                inside.toggle()
            }
            j = i
        }
        return inside
    }

    static func minVertexDistance(_ p: SIMD2<Double>, _ poly: [SIMD2<Double>]) -> Double {
        poly.map { simd_length($0 - p) }.min() ?? .infinity
    }

    /// Up to `maxPoints` sample points inside the outer ring, on a grid shaped by the bbox aspect.
    static func sampleGrid(in outer: [SIMD2<Double>], maxPoints: Int = 9) -> [SIMD2<Double>] {
        let xs = outer.map(\.x), ys = outer.map(\.y)
        guard let minX = xs.min(), let maxX = xs.max(),
              let minY = ys.min(), let maxY = ys.max() else { return [] }
        let w = maxX - minX, h = maxY - minY
        let aspect = w / max(1, h)
        let cols = max(1, Int((Double(maxPoints) * aspect).squareRoot().rounded()))
        let rows = max(1, Int((Double(maxPoints) / Double(cols)).rounded()))
        var pts: [SIMD2<Double>] = []
        for r in 0..<rows {
            for c in 0..<cols {
                let p = SIMD2(minX + w * (Double(c) + 0.5) / Double(cols),
                              minY + h * (Double(r) + 0.5) / Double(rows))
                if pointInPolygon(p, outer) { pts.append(p) }
            }
        }
        if pts.count < 3 {
            var cx = 0.0, cy = 0.0
            for p in outer { cx += p.x; cy += p.y }
            pts = [SIMD2(cx / Double(outer.count), cy / Double(outer.count))]
            for f in [0.25, 0.75] {
                let p = SIMD2(minX + w * f, minY + h * f)
                if pointInPolygon(p, outer) { pts.append(p) }
            }
        }
        return Array(pts.prefix(maxPoints))
    }

    /// Join way segments (relation members) into closed rings by matching endpoints.
    static func stitchRings(_ segments: [[SIMD2<Double>]]) -> [[SIMD2<Double>]] {
        func same(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Bool {
            abs(a.x - b.x) < 1e-7 && abs(a.y - b.y) < 1e-7
        }
        var pool = segments.filter { $0.count > 1 }
        var rings: [[SIMD2<Double>]] = []
        while !pool.isEmpty {
            var ring = pool.removeFirst()
            var grew = true
            while grew, let head = ring.last, let first = ring.first, !same(head, first) {
                grew = false
                for (i, seg) in pool.enumerated() {
                    if same(head, seg[0]) {
                        ring.append(contentsOf: seg.dropFirst()); pool.remove(at: i); grew = true; break
                    }
                    if same(head, seg[seg.count - 1]) {
                        ring.append(contentsOf: seg.dropLast().reversed()); pool.remove(at: i); grew = true; break
                    }
                }
            }
            if ring.count > 3 { rings.append(ring) }
        }
        return rings.sorted { $0.count > $1.count }
    }
}

// MARK: - Microclimate

enum Microclimate {
    /// Forecast grids are km-scale, so raw temps barely differ inside one park.
    /// Estimate a per-spot feels-like: shelter wins back wind chill, tree shade
    /// cools in daytime sun, water edges run slightly cool.
    static func evaluate(at p: SIMD2<Double>, weather: SpotWeather,
                         features: ParkFeatures) -> (feels: Double, descriptor: String) {
        let treesNear = features.trees.filter { simd_length($0 - p) < 40 }.count
        let inWood = features.woods.contains { Geo.pointInPolygon(p, $0) }
        var shelter = min(1, Double(treesNear) / 8)
        if inWood { shelter = max(shelter, 0.85) }
        let nearWater = features.water.contains {
            Geo.pointInPolygon(p, $0) || Geo.minVertexDistance(p, $0) < 60
        }

        let chill = min(0, weather.apparent - weather.temperature)
        let windRecovery = shelter * -chill * 0.7
        let shadeAdjust = weather.isDay ? -(shelter * 2.2) : shelter * 0.6
        let waterAdjust = nearWater ? -0.9 : 0.0
        let feels = weather.apparent + windRecovery + shadeAdjust + waterAdjust

        var bits: [String] = []
        if inWood { bits.append("under tree canopy") }
        else if treesNear > 2 { bits.append("\(treesNear) trees nearby") }
        if nearWater { bits.append("near water") }
        return (feels, bits.isEmpty ? "open ground" : bits.joined(separator: ", "))
    }
}
