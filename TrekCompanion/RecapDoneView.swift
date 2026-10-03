import SwiftUI

struct RecapDoneView: View {
    let dayNumber: Int
    let summary: RecapSummary
    let onDone: () -> Void

    private var detail: String {
        let photos = "\(summary.photoCount) \(summary.photoCount == 1 ? "photo" : "photos")"
        let places = "\(summary.placeCount) \(summary.placeCount == 1 ? "place" : "places")"
        let skipped = summary.skippedCount > 0 ? ", \(summary.skippedCount) skipped" : ""
        let upload = summary.photoCount > 0 ? " Photos upload in the background, so you can close the app." : ""
        return "\(photos) on \(places)\(skipped).\(upload)"
    }

    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.trekSuccess)
            Text("Day \(dayNumber) added to your Journey")
                .font(.poppins(22, .bold, relativeTo: .title2))
                .foregroundStyle(Color.trekText)
                .multilineTextAlignment(.center)
            Text(detail)
                .font(.poppins(15, relativeTo: .body))
                .foregroundStyle(Color.trekMuted)
                .multilineTextAlignment(.center)
            Spacer()
            Button("Done", action: onDone)
                .buttonStyle(TrekButtonStyle())
        }
        .padding(24)
    }
}
