import SwiftUI

struct TravelLegLabel: View {
    let leg: TravelLeg

    private var distance: String {
        Measurement(value: leg.meters, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }

    var body: some View {
        Label(
            leg.isTransit ? "\(leg.minutes) min by transit · \(distance)" : "\(leg.minutes) min walk · \(distance)",
            systemImage: leg.isTransit ? "tram.fill" : "figure.walk"
        )
            .font(.poppins(11, relativeTo: .caption2))
            .foregroundStyle(Color.trekFaint)
    }
}

extension TravelLeg {
    var shortText: String {
        isTransit ? "\(minutes) min" : "\(minutes) min walk"
    }
}
