import SwiftUI

struct JourneyProgressLine: View {
    let departs: Date
    let arrives: Date?
    let now: Date

    private var progress: Double {
        guard let arrives, arrives > departs else { return now >= departs ? 1 : 0 }
        return min(max(now.timeIntervalSince(departs) / arrives.timeIntervalSince(departs), 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.2))
                Capsule().fill(Color.widgetDone).frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 3)
        .frame(maxWidth: .infinity)
    }
}
