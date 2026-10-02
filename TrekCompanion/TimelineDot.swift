import SwiftUI

struct TimelineDot: View {
    let number: Int
    let state: StopRow.StopState
    var isOnGlass = false

    var body: some View {
        ZStack {
            if state == .done {
                if isOnGlass { Circle().fill(.primary.opacity(0.14)) }
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.trekSuccess)
            } else {
                if state == .next {
                    Circle().fill(Color.trekAccent)
                } else if isOnGlass {
                    Circle().fill(.primary.opacity(0.14))
                } else {
                    Circle().fill(Color.trekCard)
                    Circle().strokeBorder(state == .upcoming ? Color.trekBorder : .clear, lineWidth: 1.5)
                }
                Text("\(number)")
                    .font(.poppins(11, .bold))
                    .foregroundStyle(state == .next ? AnyShapeStyle(Color.trekAccentText) : isOnGlass ? AnyShapeStyle(.primary) : AnyShapeStyle(Color.trekMuted))
            }
        }
        .frame(width: 26, height: 26)
        .background(isOnGlass ? .clear : Color.trekBackground)
    }
}
