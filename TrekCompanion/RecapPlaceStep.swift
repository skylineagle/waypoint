import SwiftUI

struct RecapPlaceStep: View {
    @Bindable var model: RecapModel
    @FocusState private var isWriting: Bool

    private var place: RecapPlace { model.places[model.index] }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 4)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    if let time = place.time {
                        Text(time)
                            .font(.poppins(13, .semibold, relativeTo: .footnote))
                            .foregroundStyle(Color.trekMuted)
                    }
                    Text(place.stop.place.name)
                        .font(.poppins(24, .bold, relativeTo: .title))
                        .foregroundStyle(Color.trekText)
                }
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
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .task(id: model.index) { await model.draftIfNeeded() }
    }
}
