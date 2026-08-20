import SwiftUI

enum HPTheme {
    static let bg = Color.black
    static let cardBG = Color(white: 0.08)
    static let neon = Color(red: 0, green: 1, blue: 0)
    static let neonDim = Color(red: 0, green: 0.6, blue: 0)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.5)
    static let mono = Font.system(.body, design: .monospaced)
    static let monoSmall = Font.system(.caption, design: .monospaced)
    static let monoLarge = Font.system(.title2, design: .monospaced).weight(.bold)
    static let monoTitle = Font.system(.title, design: .monospaced).weight(.bold)
}
