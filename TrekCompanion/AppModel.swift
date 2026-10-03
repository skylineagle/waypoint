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
    var tab = MainTab.today
    var isAddingExpense = false
    var isConverting = false
    var editingExpense: ExpenseLink?
    var converterAmount = 100.0
    var openedBookingID: Int?

    func select(_ trip: Trip?) {
        guard var latest = Account.load() else { return }
        latest.trip = trip
        account = latest
    }

    func openConverter(from url: URL) {
        let amount = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first { $0.name == "amount" }?.value.flatMap(Double.init)
        converterAmount = amount.flatMap { $0 > 0 ? $0 : nil } ?? 100
        isConverting = true
    }

    func openExpense(from url: URL) {
        guard let id = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "id" })?.value.flatMap(Int.init)
        else { return }
        tab = .costs
        editingExpense = ExpenseLink(id: id)
    }

    func signOut() {
        if let scope = JourneySession.load()?.scope { Task { await JourneyUploader.pause(scope: scope) } }
        account = nil
        isShortcutSetUp = false
        TodaySnapshot.clear()
        Task { await ReminderScheduler.clear() }
        WidgetPhotoStore.clear()
        StopTracker.shared.sync(isActive: false)
        Task { await TripLiveActivity.sync(with: nil) }
    }
}
