import Foundation
import AVFoundation
import SwiftUI

struct AudioMetrics: Equatable {
    var frequencies: [Float] = Array(repeating: 0, count: 32)
    var beat: Bool = false
    var energy: Float = 0
    var timestamp: TimeInterval = 0
}

struct AudioFileMetadata {
    let url: URL
    let duration: TimeInterval
    let filename: String
}

enum VisualizationProgram: CaseIterable {
    case beatDriven
    case frequencyBand
    case hybrid

    var name: String {
        switch self {
        case .beatDriven: return "Beat-Driven"
        case .frequencyBand: return "Frequency-Band"
        case .hybrid: return "Hybrid"
        }
    }

    mutating func next() {
        switch self {
        case .beatDriven: self = .frequencyBand
        case .frequencyBand: self = .hybrid
        case .hybrid: self = .beatDriven
        }
    }
}

struct Pipe {
    var x: CGFloat
    var y: CGFloat
    var angle: Double
    var length: CGFloat
    var thickness: CGFloat
    var age: TimeInterval
    var hue: Double
}

struct ColorPalette {
    static let darkBackground = Color(red: 0.04, green: 0.1, blue: 0.1)
    static let primaryGlow = Color(red: 1.0, green: 0.53, blue: 0.0)
    static let secondaryGlow = Color(red: 0.0, green: 1.0, blue: 0.5)
    static let glowIntensity: CGFloat = 0.8
}
