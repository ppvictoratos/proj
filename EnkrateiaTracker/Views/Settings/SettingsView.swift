import SwiftUI

struct SettingsView: View {
    @StateObject private var programManager = ProgramSelectionViewModel()
    @State private var notificationsEnabled = false
    @State private var dailyTime = Date()

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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Training Program")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)

                            Picker("Program", selection: $programManager.selectedProgram) {
                                ForEach(programManager.availablePrograms, id: \.self) { program in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(program.displayName)
                                            .font(.caption)
                                        Text(program.description)
                                            .font(.caption2)
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    .tag(program)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(12)
                        .background(Theme.cardBG)
                        .cornerRadius(8)

                        Toggle("Notifications", isOn: $notificationsEnabled)
                            .foregroundColor(Theme.textPrimary)
                            .tint(Theme.accentCyan)
                            .padding(12)
                            .background(Theme.cardBG)
                            .cornerRadius(8)

                        if notificationsEnabled {
                            NavigationLink(destination: NotificationScheduleView()) {
                                HStack {
                                    Text("Notification Time")
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Text(dailyTime.formatted(time: .shortened))
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
            .onChange(of: notificationsEnabled) { _, enabled in
                if enabled {
                    NotificationService.shared.requestNotificationPermission()
                } else {
                    NotificationService.shared.cancelNotifications()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
