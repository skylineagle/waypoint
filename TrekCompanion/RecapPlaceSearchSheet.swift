import CoreLocation
import SwiftUI

struct RecapPlaceSearchSheet: View {
    let coordinate: CLLocationCoordinate2D
    let onChoose: (RecapCandidate) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [RecapCandidate] = []

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            List {
                if !results.isEmpty {
                    Section("Near this spot") {
                        ForEach(results) { candidate in
                            Button {
                                onChoose(candidate)
                                dismiss()
                            } label: {
                                RecapCandidateRow(candidate: candidate, isChosen: false)
                            }
                        }
                    }
                }
            }
            .overlay {
                if results.isEmpty, !trimmedQuery.isEmpty { ContentUnavailableView.search(text: trimmedQuery) }
            }
            .navigationTitle("Where were you?")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Restaurant, shop, landmark")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .task(id: trimmedQuery) {
                guard !trimmedQuery.isEmpty else { return results = [] }
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                results = await RecapPlaceFinder.search(trimmedQuery, near: coordinate)
            }
        }
    }
}
