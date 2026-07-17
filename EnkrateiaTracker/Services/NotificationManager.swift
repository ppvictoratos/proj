import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    @Published var notificationsEnabled = false
    @Published var scheduledTime = DateComponents(hour: 7, minute: 0)

    private let defaults = UserDefaults.standard

    init() {
        self.notificationsEnabled = defaults.bool(forKey: "notificationsEnabled")

        if let hourStored = defaults.integer(forKey: "notifHour") as Int? {
            let minStored = defaults.integer(forKey: "notifMinute") as Int?
            scheduledTime = DateComponents(hour: hourStored, minute: minStored ?? 0)
        }
    }

    func enableNotifications(at time: DateComponents) {
        NotificationService.shared.requestNotificationPermission()

        TetradCycleService.shared.getOrCreateCycle()
        let cycle = TetradCycleService.shared.getOrCreateCycle()

        // Schedule for each day of the cycle
        for day: TetradDay in [.day1, .day2, .day3, .day4] {
            NotificationService.shared.scheduleWorkoutNotification(for: day, at: time)
        }

        notificationsEnabled = true
        scheduledTime = time

        defaults.set(true, forKey: "notificationsEnabled")
        defaults.set(time.hour ?? 7, forKey: "notifHour")
        defaults.set(time.minute ?? 0, forKey: "notifMinute")
    }

    func disableNotifications() {
        NotificationService.shared.cancelNotifications()
        notificationsEnabled = false
        defaults.set(false, forKey: "notificationsEnabled")
    }
}
