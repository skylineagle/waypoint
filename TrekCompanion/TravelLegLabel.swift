import SwiftUI

struct TravelLegLabel: View {
    let leg: TravelLeg
    var isOnGlass = false

    private var distance: String {
        Measurement(value: leg.meters, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: leg.isTransit ? "tram.fill" : "figure.walk")
                .font(.system(size: 10, weight: .semibold))
                .frame(width: 20, height: 20)
                .background(isOnGlass ? AnyShapeStyle(.primary.opacity(0.14)) : AnyShapeStyle(Color.trekBackground), in: .circle)
                .frame(width: 26)
            Text(leg.isTransit ? "\(leg.minutes) min by transit · \(distance)" : "\(leg.minutes) min walk · \(distance)")
                .font(.poppins(11, relativeTo: .caption2))
        }
        .foregroundStyle(isOnGlass ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.trekFaint))
        .accessibilityElement(children: .combine)
    }
}

extension TravelLeg {
    var shortText: String {
        isTransit ? "\(minutes) min" : "\(minutes) min walk"
    }
}
