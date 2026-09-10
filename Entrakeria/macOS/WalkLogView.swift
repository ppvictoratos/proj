import SwiftUI

struct WalkLogView: View {
    @Binding var activeView: String?
    @State private var activity = ""
    @State private var location = ""
    @State private var duration = ""

    var body: some View {
        ZStack {
            EntrakeiaPalette.bg.ignoresSafeArea()

            VStack(spacing: 30) {
                HStack {
                    Button(action: { activeView = nil }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(EntrakeiaPalette.blue)
                    }
                    Spacer()
                }
                .padding(20)

                Text("WALK")
                    .font(.system(size: 28, weight: .semibold))
                    .tracking(4)
                    .foregroundStyle(EntrakeiaPalette.accent)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(EntrakeiaPalette.line)
                        TextField("e.g., dog walk, morning stroll", text: $activity)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Where")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(EntrakeiaPalette.line)
                        TextField("e.g., park, neighborhood", text: $location)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(EntrakeiaPalette.line)
                        TextField("e.g., 30 min, 45 minutes", text: $duration)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(20)
                .background(EntrakeiaPalette.card)
                .cornerRadius(8)

                Button(action: { activeView = nil }) {
                    Text("LOG WALK")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(EntrakeiaPalette.blue)
                        .foregroundStyle(EntrakeiaPalette.bg)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(40)
        }
        .frame(minWidth: 800, minHeight: 1000)
    }
}

#Preview {
    WalkLogView(activeView: .constant(nil))
}
