import SwiftUI

struct TimelineDot: View {
    let number: Int
    let state: StopRow.StopState

    var body: some View {
        ZStack {
            if state == .done {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.trekSuccess)
            } else {
                Circle().fill(state == .next ? Color.trekAccent : Color.trekCard)
                Circle().strokeBorder(state == .upcoming ? Color.trekBorder : .clear, lineWidth: 1.5)
                Text("\(number)")
                    .font(.poppins(11, .bold))
                    .foregroundStyle(state == .next ? Color.trekAccentText : Color.trekMuted)
            }
        }
        .frame(width: 26, height: 26)
        .background(Color.trekBackground)
    }
}
