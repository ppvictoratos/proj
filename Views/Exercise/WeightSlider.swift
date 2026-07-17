import SwiftUI

struct WeightSlider: View {
    @Binding var weight: Double
    let max: Double = 300

    private let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.63)
    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    private let textLight = Color(red: 0.91, green: 0.91, blue: 0.91)

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Weight")
                    .foregroundColor(textSecondary)
                Spacer()
                Text(String(format: "%.0f lbs", weight))
                    .font(.caption)
                    .foregroundColor(accentCyan)
            }

            Slider(value: $weight, in: 0...max, step: 5)
                .tint(accentCyan)
        }
    }
}

#Preview {
    @State var weight = 50.0
    return ZStack {
        Color(red: 0.04, green: 0.04, blue: 0.04).ignoresSafeArea()
        WeightSlider(weight: $weight)
            .padding()
    }
}
