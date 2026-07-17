import SwiftUI

struct RotatedSquareView: View {
    let exercises: [Exercise]
    let onCornerTap: (Exercise) -> Void

    private let accentCyan = Color(red: 0.13, green: 0.8, blue: 0.8)
    let squareSize: CGFloat = 200

    var body: some View {
        ZStack {
            // Rotated square outline (diamond)
            RoundedRectangle(cornerRadius: 8)
                .stroke(accentCyan, lineWidth: 2)
                .frame(width: squareSize, height: squareSize)
                .rotationEffect(.degrees(45))

            // 4 corners with exercise buttons
            VStack(spacing: squareSize - 60) {
                HStack(spacing: squareSize - 60) {
                    if exercises.count > 0 {
                        CornerButton(exercise: exercises[0], action: {
                            onCornerTap(exercises[0])
                        })
                    }
                    Spacer()
                    if exercises.count > 1 {
                        CornerButton(exercise: exercises[1], action: {
                            onCornerTap(exercises[1])
                        })
                    }
                }

                Spacer()

                HStack(spacing: squareSize - 60) {
                    if exercises.count > 2 {
                        CornerButton(exercise: exercises[2], action: {
                            onCornerTap(exercises[2])
                        })
                    }
                    Spacer()
                    if exercises.count > 3 {
                        CornerButton(exercise: exercises[3], action: {
                            onCornerTap(exercises[3])
                        })
                    }
                }
            }
            .frame(width: squareSize, height: squareSize)
        }
        .frame(height: 300)
    }
}

#Preview {
    ZStack {
        Color(red: 0.04, green: 0.04, blue: 0.04).ignoresSafeArea()
        RotatedSquareView(
            exercises: Constants.tetradExercises[.day1] ?? [],
            onCornerTap: { _ in }
        )
    }
}
