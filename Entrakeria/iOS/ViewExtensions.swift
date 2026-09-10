import SwiftUI

extension View {
    func borderBottom(height: CGFloat, color: Color) -> some View {
        VStack {
            self
            Divider().frame(height: height).background(color)
        }
    }
}
