import Foundation

nonisolated struct ConverterState: Codable, Hashable, Sendable {
    let tripTitle: String
    let tripCurrency: String
    let displayCurrency: String
    var rate: Double
    var entry: String
    var lastKeyAt: Date?

    private static let key = "converter-state"
    private static let defaultEntry = "100"
    private static let maxEntryLength = 9
    private static let sequenceGap: TimeInterval = 4
    private static let ladderSize = 30

    static func load() -> ConverterState? {
        guard let data = AppGroup.defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ConverterState.self, from: data)
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        AppGroup.defaults.set(data, forKey: Self.key)
    }

    static func publish(tripTitle: String, tripCurrency: String, displayCurrency: String, rate: Double) {
        ConverterState(
            tripTitle: tripTitle,
            tripCurrency: tripCurrency,
            displayCurrency: displayCurrency,
            rate: rate,
            entry: load()?.entry ?? defaultEntry,
            lastKeyAt: nil
        ).save()
    }

    var amount: Double { Double(entry) ?? 0 }

    var converted: Double { amount * rate }

    mutating func type(_ key: String, at now: Date = .now) {
        let startsSequence = lastKeyAt.map { now.timeIntervalSince($0) > Self.sequenceGap } ?? true
        lastKeyAt = now
        switch key {
        case "⌫":
            entry = entry.count > 1 ? String(entry.dropLast()) : "0"
        case ".":
            if startsSequence { entry = "0." } else if !entry.contains(".") { entry += "." }
        default:
            if startsSequence { entry = key; return }
            guard entry.count < Self.maxEntryLength else { return }
            entry = entry == "0" ? key : entry + key
        }
    }

    mutating func step(_ direction: Int) {
        let current = amount
        let index = direction > 0
            ? (0..<Self.ladderSize).first { Self.ladder($0) > current } ?? Self.ladderSize - 1
            : (0..<Self.ladderSize).last { Self.ladder($0) < current } ?? 0
        entry = String(Int(Self.ladder(index)))
        lastKeyAt = nil
    }

    private static func ladder(_ index: Int) -> Double {
        [1.0, 2, 5][index % 3] * pow(10, Double(index / 3))
    }
}
