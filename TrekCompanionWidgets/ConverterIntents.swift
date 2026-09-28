import AppIntents
import WidgetKit

nonisolated private func updateConverter(_ change: (inout ConverterState) -> Void) {
    guard var state = ConverterState.load() else { return }
    change(&state)
    state.save()
    WidgetCenter.shared.reloadAllTimelines()
}

struct ConverterKeyIntent: AppIntent {
    static let title: LocalizedStringResource = "Enter Amount"
    static let isDiscoverable = false

    @Parameter(title: "Key") var key: String

    init() {}

    init(key: String) {
        self.key = key
    }

    func perform() async throws -> some IntentResult {
        updateConverter { $0.type(key) }
        return .result()
    }
}

struct ConverterStepIntent: AppIntent {
    static let title: LocalizedStringResource = "Step Amount"
    static let isDiscoverable = false

    @Parameter(title: "Direction") var direction: Int

    init() {}

    init(direction: Int) {
        self.direction = direction
    }

    func perform() async throws -> some IntentResult {
        updateConverter { $0.step(direction) }
        return .result()
    }
}

nonisolated struct RefreshRatesIntent: AppIntent {
    static let title: LocalizedStringResource = "Refresh Exchange Rate"
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        guard let state = ConverterState.load(),
              let rates = try? await ExchangeRates.fetch(base: state.tripCurrency),
              let rate = rates[state.displayCurrency]
        else { return .result() }
        updateConverter { $0.rate = rate }
        return .result()
    }
}
