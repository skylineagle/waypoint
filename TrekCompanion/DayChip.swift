import SwiftUI

struct DayChip: View {
    let day: TripDay
    let number: Int
    let segment: TripSegment?
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    private var date: Date? { ExpenseDate.date(from: day.date) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Text(date?.formatted(.dateTime.weekday(.abbreviated)).uppercased() ?? "DAY")
                    .font(.poppins(9.5, .semibold, relativeTo: .caption2))
                    .tracking(0.6)
                    .opacity(0.65)
                Text(date?.formatted(.dateTime.day()) ?? "\(number)")
                    .font(.poppins(17, .bold, relativeTo: .headline))
                    .monospacedDigit()
                Circle()
                    .fill(isToday ? Color.trekSuccess : .clear)
                    .frame(width: 5, height: 5)
            }
            .foregroundStyle(isSelected ? Color.trekAccentText : Color.trekText)
            .frame(width: 46, height: 60)
            .contentShape(.rect(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 18).fill(Color.trekAccent)
            } else if let tint = segment?.tint {
                RoundedRectangle(cornerRadius: 18).fill(tint.opacity(0.12))
            } else {
                RoundedRectangle(cornerRadius: 18).fill(Color.trekSecondaryFill)
            }
        }
        .overlay {
            if isSelected, let tint = segment?.tint {
                RoundedRectangle(cornerRadius: 18).strokeBorder(tint, lineWidth: 1.5)
            }
        }
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var accessibilityText: String {
        let title = "Day \(number)" + (date.map { ", \($0.formatted(date: .complete, time: .omitted))" } ?? "") + (segment.map { ", \($0.name)" } ?? "")
        return isToday ? "\(title), today" : title
    }
}
