import Foundation
import UserNotifications

nonisolated enum JourneyNotice {
    static let enabledKey = "notify-photo-uploads"

    static var isEnabled: Bool {
        UserDefaults(suiteName: JourneyStore.group)?.object(forKey: enabledKey) as? Bool ?? true
    }

    static func post(for upload: JourneyUpload) {
        let stuck = upload.photos.filter { $0.state == .failed || $0.state == .uncertain || $0.state == .signIn }
        guard isEnabled, !stuck.isEmpty else { return }
        let content = UNMutableNotificationContent()
        content.title = stuck.count == 1 ? "1 photo wasn't sent" : "\(stuck.count) photos weren't sent"
        content.body = stuck.contains { $0.state == .signIn }
            ? "Sign in to TREK to finish sending them to \(upload.destination.title)."
            : "Open Waypoint to retry sending them to \(upload.destination.title)."
        content.sound = .default
        content.threadIdentifier = "photo-uploads"
        content.userInfo = ["url": "trekcompanion://settings"]
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "journey-upload-\(upload.id)", content: content, trigger: nil))
    }
}
