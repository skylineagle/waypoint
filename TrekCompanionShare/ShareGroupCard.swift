import SwiftUI

struct ShareGroupCard: View {
    let group: ShareGroup
    let stops: [JourneyStop]
    let onAssign: (JourneyStop) -> Void

    private static let visibleThumbnails = 4
    private var isUnplaced: Bool { group.stop == nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if isUnplaced {
                    Image(systemName: "questionmark.circle.fill").foregroundStyle(Color.trekWarning)
                }
                Text(group.stop?.name ?? "Which stop?").font(.poppins(15, .semibold))
                Spacer()
                Text(Self.dayLabel(group.day)).font(.poppins(12)).foregroundStyle(Color.trekMuted)
            }
            HStack(spacing: 4) {
                ForEach(group.files.prefix(Self.visibleThumbnails), id: \.self) { file in
                    if let thumbnail = JourneyPhoto.thumbnail(file) {
                        Image(uiImage: thumbnail).resizable().scaledToFill()
                            .frame(width: 52, height: 52).clipShape(.rect(cornerRadius: 8))
                            .accessibilityLabel("Selected photo")
                    }
                }
                if group.files.count > Self.visibleThumbnails {
                    Text("+\(group.files.count - Self.visibleThumbnails)")
                        .font(.poppins(12, .medium)).frame(width: 52, height: 52)
                        .background(Color.trekSecondaryFill, in: .rect(cornerRadius: 8))
                }
            }
            if isUnplaced {
                VStack(spacing: 6) {
                    ForEach(stops) { stop in
                        Button { onAssign(stop) } label: {
                            HStack(spacing: 8) {
                                Text(stop.entryTime ?? "").font(.poppins(12)).foregroundStyle(Color.trekMuted)
                                Text(stop.name).font(.poppins(13))
                                Spacer()
                            }
                            .padding(.horizontal, 10).padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.trekBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 10)
                .overlay(alignment: .leading) { Rectangle().fill(Color.trekWarning.opacity(0.5)).frame(width: 2) }
            }
        }
        .padding(12)
        .background(isUnplaced ? Color.trekWarning.opacity(0.1) : Color.trekInput, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(isUnplaced ? Color.trekWarning : .clear, lineWidth: 1.5))
    }

    private static func dayLabel(_ day: String?) -> String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        guard let day, let date = parser.date(from: day) else { return "" }
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}
