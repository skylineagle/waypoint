import SwiftUI

struct ReceiptTile: View {
    let image: UIImage?
    let savedCount: Int
    let isReading: Bool
    let onScan: (() -> Void)?
    let onChoosePhoto: () -> Void

    var body: some View {
        Menu {
            if let onScan {
                Button("Scan receipt", systemImage: "doc.text.viewfinder", action: onScan)
            }
            Button("Choose photo", systemImage: "photo.on.rectangle", action: onChoosePhoto)
        } label: {
            if let image {
                scanned(image)
            } else {
                empty
            }
        }
        .buttonStyle(.plain)
        .disabled(isReading)
    }

    private func scanned(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .clipShape(.rect(cornerRadius: 14))
            .overlay(alignment: .bottomTrailing) {
                label(isReading ? "Reading…" : "Retake", symbol: isReading ? "text.viewfinder" : "arrow.counterclockwise")
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: .capsule)
                    .padding(8)
            }
            .accessibilityLabel(isReading ? "Reading receipt" : "Receipt photo, retake")
    }

    private var empty: some View {
        label(emptyTitle, symbol: "doc.text.viewfinder")
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(Color.trekInput, in: .rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.trekFaint, style: StrokeStyle(lineWidth: 1.2, dash: [5, 4])))
    }

    private var emptyTitle: String {
        savedCount > 0 ? "Receipt on Trek · Scan another" : "Scan receipt"
    }

    private func label(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.poppins(13, .semibold, relativeTo: .subheadline))
            .foregroundStyle(Color.trekText)
    }
}
