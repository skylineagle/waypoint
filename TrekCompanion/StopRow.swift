import SwiftUI

struct StopRow: View {
    enum StopState {
        case done, next, upcoming
    }

    let stop: TripStop
    let number: Int
    var booking: Reservation?
    let state: StopState
    var isHighlighted = false
    @State private var isExpanded = false
    var onToggle: (() -> Void)?

    private var isDone: Bool { state == .done }

    var body: some View {
        HStack(alignment: isDone ? .center : .top, spacing: 10) {
            if let onToggle {
                Button(action: onToggle) {
                    TimelineDot(number: number, state: state)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isDone ? "Mark \(stop.place.name) not done" : "Mark \(stop.place.name) done")
            } else {
                TimelineDot(number: number, state: state)
            }

            HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(stop.place.name)
                        .font(.poppins(isDone ? 13 : 14, isDone ? .medium : .semibold))
                        .foregroundStyle(isDone ? Color.trekMuted : Color.trekText)
                        .strikethrough(isDone, color: Color.trekFaint)
                    if let booking, !isDone { BookedBadge(reservation: booking) }
                }
                if !isDone, let detail = stop.notes ?? stop.place.address {
                    Text(detail)
                        .font(.poppins(11.5, relativeTo: .caption))
                        .foregroundStyle(Color.trekMuted)
                        .lineLimit(isExpanded ? nil : 1)
                        .fixedSize(horizontal: false, vertical: isExpanded)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if !isDone {
                Button("Directions to \(stop.place.name)", systemImage: "arrow.triangle.turn.up.right.diamond.fill") {
                    Directions.open(to: stop.place)
                }
                .labelStyle(.iconOnly)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.trekText)
                .frame(width: 34, height: 34)
                .background(Color.trekSecondaryFill, in: .circle)
                .buttonStyle(.plain)
            }
            }
            .padding(.horizontal, isDone ? 2 : 11)
            .padding(.vertical, isDone ? 3 : 9)
            .background(isDone ? Color.clear : Color.trekCard, in: .rect(cornerRadius: 14))
            .overlay {
                if !isDone {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isHighlighted ? Color.trekAccent : Color.trekBorder, lineWidth: isHighlighted ? 2 : 1)
                }
            }
            .contentShape(.rect)
            .onTapGesture { withAnimation(.snappy) { isExpanded.toggle() } }
        }
        .animation(.smooth, value: isHighlighted)
    }
}
