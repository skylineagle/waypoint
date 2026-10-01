import UIKit
import UserNotifications

final class JourneyAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let link = response.notification.request.content.userInfo["url"] as? String, let url = URL(string: link) else { return }
        await UIApplication.shared.open(url)
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        guard [JourneyUploader.appIdentifier, JourneyUploader.shareIdentifier].contains(identifier) else {
            completionHandler()
            return
        }
        let uploader = JourneyUploader.instance(identifier)
        uploader.backgroundCompletion = completionHandler
        uploader.reconnect()
    }
}
