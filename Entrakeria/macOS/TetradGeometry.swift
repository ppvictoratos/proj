import CoreGraphics
import SwiftUI

enum TetradGeometry {
    static func vertices(forDay index: Int, unit: CGFloat, centerY: CGFloat) -> [CGPoint] {
        let cx = unit * (CGFloat(index) * 2.0 + 1.0)
        let half = unit * 0.7
        return [
            CGPoint(x: cx, y: centerY - half),
            CGPoint(x: cx + half, y: centerY),
            CGPoint(x: cx, y: centerY + half),
            CGPoint(x: cx - half, y: centerY)
        ]
    }

    static func ribbonPath(days: Int, unit: CGFloat, centerY: CGFloat) -> Path {
        var path = Path()
        for d in 0..<days {
            let v = vertices(forDay: d, unit: unit, centerY: centerY)
            if d == 0 { path.move(to: v[0]) }
            for p in v { path.addLine(to: p) }
            path.addLine(to: v[0])
        }
        return path
    }
}
