import SwiftUI

struct MapStopPin: View {
    let number: Int
    let category: StopCategory?
    let isDone: Bool
    let isNext: Bool

    var body: some View {
        ZStack {
            Circle().fill(isDone ? Color.trekSuccess : Color(hex: 0x111827))
            if isDone {
                Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
            } else {
                Text("\(number)").font(.poppins(12, .bold))
            }
        }
        .foregroundStyle(.white)
        .frame(width: isNext ? 30 : 24, height: isNext ? 30 : 24)
        .overlay(Circle().strokeBorder(category?.tint ?? .white, lineWidth: 2))
        .background(Circle().fill(Color(hex: 0x111827).opacity(isNext ? 0.18 : 0)).padding(-7))
        .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        .frame(width: 44, height: 44)
        .contentShape(.circle)
    }
}
