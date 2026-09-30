import UIKit

final class JourneyAppDelegate: NSObject, UIApplicationDelegate {
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
