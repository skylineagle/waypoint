import SwiftUI

struct OutsideTripNote: View {
    let files: [URL]

    private static let visibleThumbnails = 3

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: -10) {
                ForEach(files.prefix(Self.visibleThumbnails), id: \.self) { file in
                    if let thumbnail = JourneyPhoto.thumbnail(file) {
                        Image(uiImage: thumbnail).resizable().scaledToFill()
                            .frame(width: 28, height: 28).clipShape(.rect(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.trekCard, lineWidth: 2))
                            .opacity(0.5)
                    }
                }
            }
            .accessibilityHidden(true)
            Text("\(files.count) \(files.count == 1 ? "photo is" : "photos are") outside this trip's dates and won't be sent.")
                .font(.poppins(12)).foregroundStyle(Color.trekMuted)
        }
    }
}
