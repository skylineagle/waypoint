import Photos
import SwiftUI

struct RecapPhotoTile: View {
    let asset: PHAsset
    let isSelected: Bool
    let onToggle: () -> Void
    @State private var image: UIImage?

    var body: some View {
        Button(action: onToggle) {
            Color.trekSecondaryFill
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if let image {
                        Image(uiImage: image).resizable().scaledToFill()
                    }
                }
                .clipShape(.rect(cornerRadius: 10))
                .opacity(isSelected ? 1 : 0.45)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .semibold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, isSelected ? Color.trekIndigo : .black.opacity(0.25))
                        .padding(5)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(asset.creationDate.map { "Photo from \($0.formatted(date: .omitted, time: .shortened))" } ?? "Photo")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .task(id: asset.localIdentifier) {
            image = await RecapLibrary.thumbnail(of: asset, side: 240)
        }
    }
}
