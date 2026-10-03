import SwiftUI

struct CostsHeader: View {
    let trip: Trip

    private var subtitle: String {
        [trip.title, trip.dateRange, trip.dayProgress].compactMap(\.self).joined(separator: " · ")
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text("Costs")
                    .font(.poppins(28, .bold, relativeTo: .largeTitle))
                    .tracking(-0.5)
                    .foregroundStyle(Color.trekText)
                    .accessibilityAddTraits(.isHeader)
                Text(subtitle)
                    .font(.poppins(12.5, relativeTo: .footnote))
                    .foregroundStyle(Color.trekMuted)
            }
        }
        .padding(.top, 4)
    }
}
