import SwiftUI

struct TripStopAccessory: View {
    let model: TodayModel
    let day: TripDay
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLive = TripLiveActivity.isRunning

    private var current: TripStop? {
        model.nextStop(on: day)
    }

    private var following: TripStop? {
        guard let current, let index = day.stops.firstIndex(of: current) else { return nil }
        return day.stops.dropFirst(index + 1).first
    }

    private var progress: Double {
        let done = day.stops.count { model.doneIDs.contains($0.id) }
        return Double(done) / Double(day.stops.count)
    }

    private var title: String {
        current?.place.name ?? "All \(day.stops.count) stops done"
    }

    private var subtitle: String {
        guard current != nil else { return "Nice walking today" }
        guard let following else { return "Last stop of the day" }
        guard let leg = model.legs[following.id] else { return "Next: \(following.place.name)" }
        return "\(leg.shortText) to \(following.place.name)"
    }

    var body: some View {
        HStack(spacing: 12) {
            LiveActivityRing(progress: progress, isRunning: isLive, action: toggleLiveActivity)
            if placement == .inline {
                Text(title)
                    .font(.poppins(13, .semibold, relativeTo: .subheadline))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.poppins(14, .semibold, relativeTo: .subheadline))
                    Text(subtitle)
                        .font(.poppins(11, relativeTo: .caption))
                        .foregroundStyle(Color.trekMuted)
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
                if let current {
                    Button("Mark \(current.place.name) done", systemImage: "checkmark") { markDone(current) }
                        .labelStyle(.iconOnly)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.trekAccentText)
                        .frame(width: 32, height: 32)
                        .background(Color.trekAccent, in: .circle)
                        .sensoryFeedback(.success, trigger: model.doneIDs)
                }
            }
        }
        .foregroundStyle(Color.trekText)
        .padding(.leading, 4)
        .padding(.trailing, 6)
        .animation(.smooth, value: model.doneIDs)
        .task(id: scenePhase) { isLive = TripLiveActivity.isRunning }
    }

    private func markDone(_ stop: TripStop) {
        withAnimation(.snappy) { model.toggleDone(stop) }
    }

    private func toggleLiveActivity() {
        guard let snapshot = TodaySnapshot.load() else { return }
        Task {
            if isLive {
                await TripLiveActivity.stop(for: snapshot)
            } else {
                await TripLiveActivity.start(with: snapshot)
            }
            withAnimation(.smooth) { isLive = TripLiveActivity.isRunning }
        }
    }
}
