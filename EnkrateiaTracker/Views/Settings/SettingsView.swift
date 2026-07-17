import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.darkBG.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)

                    VStack(spacing: 12) {
                        Toggle("Notifications", isOn: Binding(
                            get: { notificationManager.notificationsEnabled },
                            set: { enabled in
                                if enabled {
                                    notificationManager.enableNotifications(at: notificationManager.scheduledTime)
                                } else {
                                    notificationManager.disableNotifications()
                                }
                            }
                        ))
                        .foregroundColor(Theme.textPrimary)
                        .tint(Theme.accentCyan)
                        .padding(12)
                        .background(Theme.cardBG)
                        .cornerRadius(8)

                        if notificationManager.notificationsEnabled {
                            NavigationLink(destination: NotificationScheduleView(
                                notificationManager: notificationManager
                            )) {
                                HStack {
                                    Text("Notification Time")
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Text(String(format: "%02d:%02d",
                                               notificationManager.scheduledTime.hour ?? 7,
                                               notificationManager.scheduledTime.minute ?? 0))
                                        .foregroundColor(Theme.accentCyan)
                                }
                                .padding(12)
                                .background(Theme.cardBG)
                                .cornerRadius(8)
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
