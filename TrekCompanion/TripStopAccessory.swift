import SwiftUI

struct TripStopAccessory: View {
    let model: TodayModel
    let day: TripDay
    let onOpenPlan: () -> Void
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
        guard isLive else { return "Show today on your Lock Screen" }
        guard let following else { return "Last stop of the day" }
        guard let leg = model.legs[following.id] else { return "Next: \(following.place.name)" }
        return "\(leg.shortText) to \(following.place.name)"
    }

    var body: some View {
        HStack(spacing: 12) {
            LiveActivityRing(progress: progress, isRunning: isLive, action: toggleLiveActivity)
            Menu {
                if let current {
                    Button("Mark \(current.place.name) done", systemImage: "checkmark") { markDone(current) }
                    Button("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill") { Directions.open(to: current.place) }
                }
                Button("Open in the plan", systemImage: "list.bullet", action: onOpenPlan)
                Divider()
                Button(isLive ? "Stop Live Activity" : "Start Live Activity", systemImage: isLive ? "stop.circle" : "play.circle", action: toggleLiveActivity)
            } label: {
                details
            }
            .buttonStyle(.plain)
            if placement != .inline {
                trailingAction
            }
        }
        .foregroundStyle(Color.trekText)
        .padding(.leading, 10)
        .padding(.trailing, 8)
        .animation(.smooth, value: model.doneIDs)
        .animation(.smooth, value: isLive)
        .task(id: scenePhase) { isLive = TripLiveActivity.isRunning }
    }

    @ViewBuilder
    private var details: some View {
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
            .contentShape(.rect)
            .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder
    private var trailingAction: some View {
        if !isLive {
            Button("Start", action: toggleLiveActivity)
                .font(.poppins(13, .semibold, relativeTo: .subheadline))
                .foregroundStyle(Color.trekAccentText)
                .padding(.horizontal, 14)
                .frame(minHeight: 32)
                .background(Color.trekAccent, in: .capsule)
                .minimumHitArea(around: 32)
                .accessibilityLabel("Start Live Activity")
        } else if let current {
            Button("Mark \(current.place.name) done", systemImage: "checkmark") { markDone(current) }
                .labelStyle(.iconOnly)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.trekAccentText)
                .frame(width: 32, height: 32)
                .background(Color.trekAccent, in: .circle)
                .minimumHitArea(around: 32)
                .sensoryFeedback(.success, trigger: model.doneIDs)
        }
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
