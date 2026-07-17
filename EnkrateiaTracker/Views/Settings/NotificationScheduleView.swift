import SwiftUI

struct NotificationScheduleView: View {
    @State private var selectedTime = Date()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).opacity(0.1).ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Text("Daily Reminder")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }

                VStack(spacing: 8) {
                    Text("What time should we remind you?")
                        .foregroundColor(.gray)

                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }

                Button(action: {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
                    NotificationService.shared.scheduleWorkoutNotification(
                        for: .day1,
                        at: components
                    )
                    dismiss()
                }) {
                    Text("Save")
                        .font(.system(weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.cyan)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding(16)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NotificationScheduleView()
}
