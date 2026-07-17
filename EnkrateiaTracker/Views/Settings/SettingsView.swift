import SwiftUI

struct SettingsView: View {
    @StateObject private var programManager = ProgramSelectionViewModel()
    @State private var notificationsEnabled = false
    @State private var dailyTime = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).opacity(0.1).ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)

                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Training Program")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Picker("Program", selection: $programManager.selectedProgram) {
                                ForEach(programManager.availablePrograms, id: \.self) { program in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(program.displayName)
                                            .font(.caption)
                                        Text(program.description)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .tag(program)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(12)
                        .background(Color(UIColor.systemGray6).opacity(0.3))
                        .cornerRadius(8)

                        Toggle("Notifications", isOn: $notificationsEnabled)
                            .foregroundColor(.white)
                            .tint(.cyan)
                            .padding(12)
                            .background(Color(UIColor.systemGray6).opacity(0.3))
                            .cornerRadius(8)

                        if notificationsEnabled {
                            NavigationLink(destination: NotificationScheduleView()) {
                                HStack {
                                    Text("Notification Time")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(dailyTime.formatted(time: .shortened))
                                        .foregroundColor(.cyan)
                                }
                                .padding(12)
                                .background(Color(UIColor.systemGray6).opacity(0.3))
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
