import SwiftUI

struct StayCard: View {
    let caption: String
    let stay: Stay

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CostCategory.accommodation.color)
                .frame(width: 34, height: 34)
                .background(CostCategory.accommodation.color.opacity(0.12), in: .rect(cornerRadius: 10))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                CardCaption(text: caption)
                Text(stay.placeName ?? "Hotel")
                    .font(.poppins(15, .semibold))
                    .foregroundStyle(Color.trekText)
                if let address = stay.placeAddress {
                    Text(address)
                        .font(.poppins(11.5, relativeTo: .caption))
                        .foregroundStyle(Color.trekMuted)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .trekCard()
        .accessibilityElement(children: .combine)
    }
}
