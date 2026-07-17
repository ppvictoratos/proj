import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func scheduleWorkoutNotification(for day: TetradDay, at time: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Train"
        content.body = "Today: \(day.name) — \(day.description)"
        content.sound = .default
        content.badge = NSNumber(value: 1)

        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: "tetrad-\(day.rawValue)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
