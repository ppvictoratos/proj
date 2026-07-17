import SwiftUI

struct NotificationScheduleView: View {
    let notificationManager: NotificationManager
    @State private var selectedTime = Date()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.darkBG.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Text("Daily Reminder")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                VStack(spacing: 8) {
                    Text("What time should we remind you?")
                        .foregroundColor(Theme.textSecondary)

                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }

                Button(action: {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
                    notificationManager.enableNotifications(at: components)
                    dismiss()
                }) {
                    Text("Save")
                        .font(.system(weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Theme.accentCyan)
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
    NotificationScheduleView(notificationManager: NotificationManager())
}
