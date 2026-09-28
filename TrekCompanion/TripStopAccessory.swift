import SwiftUI

struct TripStopAccessory: View {
    let model: TodayModel
    let day: TripDay
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    private var next: TripStop? {
        model.nextStop(on: day)
    }

    private var previous: TripStop? {
        let upcoming = next.flatMap { day.stops.firstIndex(of: $0) } ?? day.stops.count
        return day.stops[..<upcoming].last { model.doneIDs.contains($0.id) }
    }

    private var position: String {
        guard let next, let index = day.stops.firstIndex(of: next) else { return "\(day.stops.count)/\(day.stops.count)" }
        return "\(index + 1)/\(day.stops.count)"
    }

    private var title: String {
        next?.place.name ?? "All stops done"
    }

    var body: some View {
        HStack(spacing: 8) {
            LiveActivityButton()
            if placement == .inline {
                Text("\(title) \(position)")
                    .font(.poppins(13, .semibold, relativeTo: .subheadline))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            } else {
                stepButton("Previous stop", symbol: "chevron.left", stop: previous)
                VStack(spacing: 0) {
                    Text(title)
                        .font(.poppins(14, .semibold, relativeTo: .subheadline))
                        .lineLimit(1)
                    Text("Stop \(position.replacingOccurrences(of: "/", with: " of "))")
                        .font(.poppins(11, relativeTo: .caption))
                        .foregroundStyle(Color.trekMuted)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                stepButton("Next stop", symbol: "chevron.right", stop: next)
            }
        }
        .foregroundStyle(Color.trekText)
        .padding(.horizontal, 8)
        .animation(.smooth, value: model.doneIDs)
    }

    private func stepButton(_ label: String, symbol: String, stop: TripStop?) -> some View {
        Button(label, systemImage: symbol) {
            if let stop { model.toggleDone(stop) }
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 14, weight: .semibold))
        .frame(width: 34, height: 34)
        .background(Color.trekSecondaryFill, in: .circle)
        .disabled(stop == nil)
    }
}
