import SwiftUI

struct LiveActivityRing: View {
    let progress: Double
    let isRunning: Bool
    let action: () -> Void

    var body: some View {
        Button(isRunning ? "Stop Live Activity" : "Start Live Activity", systemImage: isRunning ? "stop.fill" : "play.fill", action: action)
            .labelStyle(.iconOnly)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Color.trekText)
            .contentTransition(.symbolEffect(.replace))
            .frame(width: 32, height: 32)
            .background {
                Circle().stroke(Color.trekSecondaryFill, lineWidth: 2.5)
                Circle()
                    .trim(from: 0, to: max(progress, 0.02))
                    .stroke(isRunning ? Color.trekSuccess : Color.trekMuted, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .sensoryFeedback(.impact(weight: .light), trigger: isRunning)
    }
}
