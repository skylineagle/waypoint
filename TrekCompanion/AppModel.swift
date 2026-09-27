import Foundation
import Observation

@Observable
final class AppModel {
    private static let shortcutSetUpKey = "isShortcutSetUp"

    var account = Account.load() {
        didSet {
            if let account { account.save() } else { Account.delete() }
        }
    }

    var isShortcutSetUp = UserDefaults.standard.bool(forKey: shortcutSetUpKey) {
        didSet { UserDefaults.standard.set(isShortcutSetUp, forKey: Self.shortcutSetUpKey) }
    }

    var shortcutCheck = ShortcutCheck.idle
    var isAddingExpense = false

    func select(_ trip: Trip?) {
        guard var latest = Account.load() else { return }
        latest.trip = trip
        account = latest
    }

    func signOut() {
        account = nil
        isShortcutSetUp = false
    }
}
