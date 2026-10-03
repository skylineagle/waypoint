import SwiftUI
import Observation

struct PackingCategory: Identifiable {
    let name: String
    let items: [PackingItem]

    var id: String { name }
    var packedCount: Int { items.count(where: \.isPacked) }
}

@Observable
final class PackingModel {
    static let uncategorized = "Other"
    let trip: Trip
    private(set) var items: [PackingItem]?
    private(set) var errorMessage: String?

    init(trip: Trip) {
        self.trip = trip
    }

    var packedCount: Int {
        (items ?? []).count(where: \.isPacked)
    }

    var totalCount: Int {
        items?.count ?? 0
    }

    var categories: [PackingCategory] {
        Dictionary(grouping: items ?? []) { $0.category ?? Self.uncategorized }
            .map { PackingCategory(name: $0.key, items: $0.value.sorted { !$0.isPacked && $1.isPacked }) }
            .sorted { $0.name < $1.name }
    }

    func load() async {
        guard let client = TrekClient.current else { return }
        do {
            items = try await client.packingItems(tripID: trip.id)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ input: PackingInput, editing item: PackingItem?) async throws {
        guard let client = TrekClient.current else { return }
        let saved = if let item {
            try await client.updatePackingItem(id: item.id, input, tripID: trip.id)
        } else {
            try await client.addPackingItem(input, tripID: trip.id)
        }
        var updated = items ?? []
        if let index = updated.firstIndex(where: { $0.id == saved.id }) {
            updated[index] = saved
        } else {
            updated.append(saved)
        }
        items = updated
    }

    func toggle(_ item: PackingItem) async {
        guard let client = TrekClient.current, let index = items?.firstIndex(of: item) else { return }
        let isPacked = !item.isPacked
        withAnimation(.smooth) { items?[index].checked = isPacked ? 1 : 0 }
        do {
            try await client.setPackingItem(id: item.id, checked: isPacked, tripID: trip.id)
        } catch {
            errorMessage = error.localizedDescription
            await load()
        }
    }

    func delete(_ item: PackingItem) async {
        guard let client = TrekClient.current else { return }
        items?.removeAll { $0.id == item.id }
        do {
            try await client.deletePackingItem(id: item.id, tripID: trip.id)
        } catch {
            errorMessage = error.localizedDescription
            await load()
        }
    }
}
