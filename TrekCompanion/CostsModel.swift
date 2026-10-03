import Foundation
import Observation
import WidgetKit

struct ExpenseDay: Identifiable {
    let date: String?
    let items: [BudgetItem]
    let total: Double?

    var id: String { date ?? "undated" }
}

struct CategoryTotal: Identifiable {
    let category: CostCategory
    let amount: Double
    let share: Double

    var id: CostCategory { category }
}

struct DailyTotal: Identifiable {
    let date: Date
    let amount: Double
    let isToday: Bool

    var id: Date { date }
}

@Observable
final class CostsModel {
    let trip: Trip
    private(set) var items: [BudgetItem]?
    private(set) var converter: CurrencyConverter
    private(set) var errorMessage: String?
    private(set) var settlement: Settlement?
    private(set) var meID: Int?
    private(set) var members: [TripMember] = []

    init(trip: Trip) {
        self.trip = trip
        converter = CurrencyConverter(displayCurrency: trip.currency, tripCurrency: trip.currency, rates: nil)
    }

    var total: Double? {
        converter.total(of: items ?? [])
    }

    var todayTotal: Double? {
        converter.total(of: (items ?? []).filter { $0.expenseDate == ExpenseDate.today })
    }

    var isShared: Bool {
        (settlement?.balances.count ?? 0) > 1
    }

    private var myBudget: Settlement.FinalBudget? {
        settlement?.finalBudgets.first { $0.userId == meID }
    }

    var myPaid: Double {
        myBudget?.expenses ?? 0
    }

    var myShare: Double {
        myBudget?.final ?? 0
    }

    var youOwe: Double {
        (settlement?.flows ?? []).filter { $0.from.userId == meID }.reduce(0) { $0 + $1.amount }
    }

    var youreOwed: Double {
        (settlement?.flows ?? []).filter { $0.to.userId == meID }.reduce(0) { $0 + $1.amount }
    }

    var owedBy: [Settlement.Person] {
        (settlement?.flows ?? []).filter { $0.to.userId == meID }.map(\.from)
    }

    var owedTo: [Settlement.Person] {
        (settlement?.flows ?? []).filter { $0.from.userId == meID }.map(\.to)
    }

    var unpaidItems: [BudgetItem] {
        (items ?? []).filter { $0.totalPrice != 0 && !$0.hasPayer }
    }

    var unpaidTotal: Double? {
        converter.total(of: unpaidItems)
    }

    func name(of userID: Int, username: String) -> String {
        userID == meID ? "You" : username
    }

    var hasStarted: Bool {
        !elapsedTripDays.isEmpty
    }

    var dailyAverage: Double? {
        guard total != nil else { return nil }
        return dailyTotals.reduce(0) { $0 + $1.amount } / Double(max(elapsedTripDays.count, 1))
    }

    var totalInTripCurrency: Double? {
        guard let total else { return nil }
        return converter.convert(total, from: converter.displayCurrency, to: trip.currency)
    }

    func days(in category: CostCategory?, unpaidOnly: Bool = false) -> [ExpenseDay] {
        let filtered = (items ?? []).filter {
            (category == nil || $0.costCategory == category) && (!unpaidOnly || ($0.totalPrice != 0 && !$0.hasPayer))
        }
        let grouped = Dictionary(grouping: filtered, by: \.expenseDate)
        return grouped
            .map { date, items in
                ExpenseDay(date: date, items: items, total: converter.total(of: items))
            }
            .sorted { ($0.date ?? "") > ($1.date ?? "") }
    }

    var categoryTotals: [CategoryTotal] {
        guard let total, total > 0 else { return [] }
        let grouped = Dictionary(grouping: items ?? [], by: \.costCategory)
        return grouped
            .map { category, items in
                let amount = converter.total(of: items) ?? 0
                return CategoryTotal(category: category, amount: amount, share: amount / total)
            }
            .sorted { $0.amount > $1.amount }
    }

    var dailyTotals: [DailyTotal] {
        guard total != nil else { return [] }
        let byDate = Dictionary(grouping: items ?? [], by: \.expenseDate)
        return elapsedTripDays.map { day in
            let key = ExpenseDate.format.format(day)
            let amount = converter.total(of: byDate[key] ?? []) ?? 0
            return DailyTotal(date: day, amount: amount, isToday: key == ExpenseDate.today)
        }
    }

    private var elapsedTripDays: [Date] {
        let calendar = Calendar.current
        guard let start = ExpenseDate.date(from: trip.startDate) else { return [] }
        let end = min(ExpenseDate.date(from: trip.endDate) ?? ExpenseDate.now, ExpenseDate.now)
        guard start <= end else { return [] }
        var days: [Date] = []
        var day = calendar.startOfDay(for: start)
        while day <= end {
            days.append(day)
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        return days
    }

    func load() async {
        guard let client = TrekClient.current else { return }
        do {
            async let loadedItems = client.expenses(tripID: trip.id)
            async let loadedMe = client.currentUserID()
            async let loadedMembers = client.members(tripID: trip.id)
            async let preferredCurrency = client.defaultCurrency()
            let displayCurrency = (try? await preferredCurrency) ?? trip.currency
            let rates = try? await ExchangeRates.fetch(base: displayCurrency)
            let converter = CurrencyConverter(displayCurrency: displayCurrency, tripCurrency: trip.currency, rates: rates)
            items = try await loadedItems
            meID = try? await loadedMe
            members = (try? await loadedMembers) ?? []
            self.converter = converter
            publishConverter()
            errorMessage = nil
            await loadSettlement()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func publishConverter() {
        guard let rate = converter.convert(1, from: converter.tripCurrency) else {
            ConverterState.clear()
            WidgetCenter.shared.reloadAllTimelines()
            return
        }
        ConverterState.publish(
            tripTitle: trip.title,
            tripCurrency: converter.tripCurrency,
            displayCurrency: converter.displayCurrency,
            rate: rate
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func loadSettlement() async {
        settlement = try? await TrekClient.current?.settlement(tripID: trip.id, currency: converter.displayCurrency)
    }

    func save(_ input: ExpenseInput, editing item: BudgetItem?, receipt: Data?) async throws {
        guard let client = TrekClient.current else { return }
        let saved = if let item {
            try await client.updateExpense(id: item.id, input, tripID: trip.id)
        } else {
            try await client.addExpense(input, tripID: trip.id)
        }
        var updated = items ?? []
        if let index = updated.firstIndex(where: { $0.id == saved.id }) {
            updated[index] = saved
        } else {
            updated.append(saved)
        }
        items = updated
        if let receipt {
            await upload(receipt, for: saved, with: client)
        }
        await loadSettlement()
    }

    private func upload(_ receipt: Data, for item: BudgetItem, with client: TrekClient) async {
        do {
            try await client.uploadReceipt(receipt, expenseID: item.id, tripID: trip.id)
            items = try await client.expenses(tripID: trip.id)
        } catch {
            errorMessage = "\(item.name) was saved, but its receipt didn't upload: \(error.localizedDescription)"
        }
    }

    func delete(_ item: BudgetItem) async {
        guard let client = TrekClient.current else { return }
        items?.removeAll { $0.id == item.id }
        do {
            try await client.deleteExpense(id: item.id, tripID: trip.id)
            await loadSettlement()
        } catch {
            errorMessage = error.localizedDescription
            await load()
        }
    }
}
