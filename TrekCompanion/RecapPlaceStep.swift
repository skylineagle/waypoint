import SwiftUI

struct RecapPlaceStep: View {
    @Bindable var model: RecapModel
    @FocusState private var isWriting: Bool
    @State private var isChoosing = false
    @State private var isSearching = false

    private var place: RecapPlace { model.places[model.index] }
    private var showsChooser: Bool { place.isSuggested && (place.name == nil || isChoosing) }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 4)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if place.isSuggested { RecapSuggestedBadge() }
                HStack(alignment: .lastTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        if let time = place.time {
                            Text(time)
                                .font(.poppins(13, .semibold, relativeTo: .footnote))
                                .foregroundStyle(Color.trekMuted)
                        }
                        Text(showsChooser ? "Where were you?" : place.name ?? "")
                            .font(.poppins(24, .bold, relativeTo: .title))
                            .foregroundStyle(Color.trekText)
                    }
                    Spacer(minLength: 8)
                    if place.isSuggested, !showsChooser {
                        Button("Change") { isChoosing = true }
                            .font(.poppins(14, .semibold, relativeTo: .subheadline))
                            .foregroundStyle(Color.trekIndigo)
                    }
                }
                if showsChooser {
                    RecapPlaceChooser(candidates: place.candidates, chosen: place.chosen, onChoose: choose) { isSearching = true }
                } else {
                    writing
                }
                photos
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .task { await model.findPlacesIfNeeded() }
        .task(id: place.name) { await model.draftIfNeeded() }
        .sheet(isPresented: $isSearching) {
            if let coordinate = place.coordinate { RecapPlaceSearchSheet(coordinate: coordinate, onChoose: choose) }
        }
    }

    private func choose(_ candidate: RecapCandidate) {
        model.choose(candidate)
        isChoosing = false
    }

    private var writing: some View {
        TextField(place.isDrafting ? "" : "What happened here?", text: $model.places[model.index].text, axis: .vertical)
            .lineLimit(3...8)
            .font(.poppins(15, relativeTo: .body))
            .focused($isWriting)
            .disabled(place.isDrafting)
            .overlay(alignment: .topLeading) {
                if place.isDrafting {
                    Label("Writing a draft…", systemImage: "sparkles")
                        .font(.poppins(15, relativeTo: .body))
                        .foregroundStyle(Color.trekMuted)
                        .symbolEffect(.pulse)
                        .phaseAnimator([0.45, 1]) { label, opacity in label.opacity(opacity) } animation: { _ in .easeInOut(duration: 0.8) }
                        .accessibilityLabel("Writing a draft")
                }
            }
            .padding(12)
            .background(Color.trekInput, in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.trekBorder))
    }

    @ViewBuilder
    private var photos: some View {
        let shown = model.orderedAssets(for: place)
        if shown.isEmpty {
            Text(model.assets.isEmpty ? "No photos from this day in your library." : "Every photo from today is already picked for another place.")
                .font(.poppins(14, relativeTo: .subheadline))
                .foregroundStyle(Color.trekMuted)
        } else {
            Text("\(place.selected.count) selected · \(place.photoIDs.count) taken here")
                .font(.poppins(13, .medium, relativeTo: .footnote))
                .foregroundStyle(Color.trekMuted)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(shown, id: \.localIdentifier) { asset in
                    RecapPhotoTile(asset: asset, isSelected: place.selected.contains(asset.localIdentifier)) {
                        model.toggle(asset.localIdentifier)
                    }
                }
            }
        }
    }
}
