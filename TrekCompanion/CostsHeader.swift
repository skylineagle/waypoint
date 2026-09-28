import SwiftUI

struct CostsHeader: View {
    let trip: Trip

    private var subtitle: String? {
        guard let range = trip.dateRange else { return nil }
        guard let progress = trip.dayProgress else { return range }
        return "\(range) · \(progress)"
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text(trip.title)
                    .font(.poppins(28, .bold, relativeTo: .largeTitle))
                    .tracking(-0.5)
                    .foregroundStyle(Color.trekText)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle {
                    Text(subtitle)
                        .font(.poppins(12.5, relativeTo: .footnote))
                        .foregroundStyle(Color.trekMuted)
                }
            }
        }
        .padding(.top, 4)
    }
}
