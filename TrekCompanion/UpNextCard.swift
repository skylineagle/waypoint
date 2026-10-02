import SwiftUI

struct UpNextCard: View {
    let stop: TripStop
    let number: Int
    let total: Int
    let leg: TravelLeg?
    var booking: Reservation?
    let onDone: () -> Void

    private var directionsTitle: String {
        guard let leg else { return "Directions" }
        return leg.shortText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("UP NEXT · \(number) OF \(total)")
                    .font(.poppins(10, .bold, relativeTo: .caption2))
                    .tracking(0.9)
                    .foregroundStyle(.white.opacity(0.55))
                if let booking { BookedBadge(reservation: booking) }
            }
            Text(stop.place.name)
                .font(.poppins(20, .bold, relativeTo: .title2))
                .padding(.top, 3)
            if let detail = stop.notes ?? stop.place.address {
                Text(detail)
                    .font(.poppins(12, relativeTo: .caption))
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
            HStack(spacing: 10) {
                Button {
                    Directions.open(to: stop.place)
                } label: {
                    Label(directionsTitle, systemImage: leg?.isTransit == true ? "tram.fill" : "arrow.triangle.turn.up.right.diamond.fill")
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)

                Button(action: onDone) {
                    Label("Done", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.white)
            }
            .font(.subheadline.weight(.semibold))
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding(.top, 14)
        }
        .foregroundStyle(Color(hex: 0xF5F5F7))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(
            LinearGradient(colors: [.trekHeroTop, .trekHeroBottom], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: .rect(cornerRadius: 20)
        )
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.trekHeroEdge))
    }
}
