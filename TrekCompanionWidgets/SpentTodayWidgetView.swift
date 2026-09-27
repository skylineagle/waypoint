import SwiftUI
import WidgetKit

struct SpentTodayWidgetView: View {
    let snapshot: TodaySnapshot?

    var body: some View {
        VStack(alignment: .leading) {
            WidgetCaption(text: snapshot?.tripTitle ?? "Today")
                .foregroundStyle(.secondary)
            Spacer()
            Text("Spent today").font(.system(size: 12)).foregroundStyle(.secondary)
            Text(snapshot?.spentToday ?? "—")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
            if let average = snapshot?.dailyAverage {
                Text("avg \(average)/day").font(.system(size: 11)).foregroundStyle(.secondary)
            }
            Label("Add", systemImage: "plus.circle.fill")
                .font(.system(size: 12, weight: .semibold))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
