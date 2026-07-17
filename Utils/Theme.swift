import SwiftUI

struct Theme {
    // Dark background colors
    static let darkBG = Color(UIColor.systemGray6).opacity(0.1)
    static let cardBG = Color(UIColor.systemGray6).opacity(0.3)

    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color.gray

    // Accent color
    static let accentCyan = Color(red: 0.2, green: 0.8, blue: 0.8)
}

extension View {
    func appBackground() -> some View {
        self.background(Theme.darkBG.ignoresSafeArea())
    }

    func cardStyle() -> some View {
        self.padding(16)
            .background(Theme.cardBG)
            .cornerRadius(12)
    }
}
