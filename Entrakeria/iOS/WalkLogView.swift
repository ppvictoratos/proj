import SwiftUI

struct WalkLogView: View {
    @Binding var activeView: String?
    @State private var activity = ""
    @State private var location = ""
    @State private var duration = ""

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Button(action: { activeView = nil }) {
                        Text("← Back")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(EntrakeiaPalette.blue)
                    }
                    Spacer()
                }
                .padding(12)

                Text("WALK")
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(EntrakeiaPalette.accent)

                VStack(spacing: 12) {
                    TextField("Activity", text: $activity)
                        .textFieldStyle(.roundedBorder)
                    TextField("Location", text: $location)
                        .textFieldStyle(.roundedBorder)
                    TextField("Duration", text: $duration)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(12)
                .background(EntrakeiaPalette.card)
                .cornerRadius(6)
                .padding(.horizontal, 12)

                Button(action: { activeView = nil }) {
                    Text("LOG")
                        .font(.system(size: 12, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(EntrakeiaPalette.blue)
                        .foregroundStyle(EntrakeiaPalette.bg)
                        .cornerRadius(6)
                }
                .padding(.horizontal, 12)

                Spacer()
            }
            .padding(12)
        }
    }
}

#Preview {
    WalkLogView(activeView: .constant(nil))
}
