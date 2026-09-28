import SwiftUI

struct LiveActivityButton: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isRunning = TripLiveActivity.isRunning

    var body: some View {
        Button(isRunning ? "Stop Live Activity" : "Start Live Activity", systemImage: isRunning ? "stop.fill" : "play.fill", action: toggle)
            .labelStyle(.iconOnly)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(isRunning ? Color.trekAccentText : Color.trekText)
            .frame(width: 34, height: 34)
            .background(isRunning ? Color.trekAccent : Color.trekSecondaryFill, in: .circle)
            .contentTransition(.symbolEffect(.replace))
            .task(id: scenePhase) { isRunning = TripLiveActivity.isRunning }
    }

    private func toggle() {
        guard let snapshot = TodaySnapshot.load() else { return }
        Task {
            if isRunning {
                await TripLiveActivity.stop(for: snapshot)
            } else {
                await TripLiveActivity.start(with: snapshot)
            }
            withAnimation(.smooth) { isRunning = TripLiveActivity.isRunning }
        }
    }
}
