import SwiftUI
import WidgetKit

struct NextStopWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: TodaySnapshot?
    private var photo: Data? { WidgetPhotoStore.load(snapshot?.photoName) }
    private var captionOpacity: Double { AppSettings.isWidgetPhotosEnabled && photo != nil ? 0.8 : 0.55 }
    private var detailOpacity: Double { AppSettings.isWidgetPhotosEnabled && photo != nil ? 0.78 : 0.6 }

    var body: some View {
        Group {
            if let snapshot, let countdown = snapshot.countdown {
                countdownView(snapshot: snapshot, countdown: countdown)
            } else if let snapshot {
                if family == .systemMedium {
                    medium(snapshot)
                } else {
                    small(snapshot)
                }
            } else {
                Text("Open Waypoint to load your trip.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .foregroundStyle(.white)
        .containerBackground(for: .widget) {
            ZStack {
                Color.widgetNight
                if AppSettings.isWidgetPhotosEnabled, let photo, let image = UIImage(data: photo) {
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .saturation(0.65)
                    }
                    LinearGradient(
                        stops: [
                            .init(color: Color.widgetNight.opacity(0.77), location: 0),
                            .init(color: Color.widgetNight.opacity(0.65), location: 0.4),
                            .init(color: Color.widgetNight.opacity(0.91), location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
        }
    }

    private func small(_ snapshot: TodaySnapshot) -> some View {
        VStack(alignment: .leading) {
            WidgetCaption(text: "Up next · \(snapshot.position)/\(snapshot.stops.count)")
                .foregroundStyle(.white.opacity(captionOpacity))
            Spacer()
            Text(snapshot.next?.name ?? "Day complete")
                .font(.system(size: 16, weight: .bold))
                .lineLimit(3)
            if let leg = snapshot.next?.leg {
                Text(leg).font(.system(size: 11)).foregroundStyle(.white.opacity(detailOpacity))
            }
            StopProgressBar(done: snapshot.doneCount, total: snapshot.stops.count)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func medium(_ snapshot: TodaySnapshot) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading) {
                WidgetCaption(text: "\(snapshot.dayLabel) · \(snapshot.dayTitle)")
                    .foregroundStyle(.white.opacity(captionOpacity))
                Spacer()
                Text(snapshot.next?.name ?? "Day complete")
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(2)
                if let leg = snapshot.next?.leg {
                    Text("Up next · \(leg)").font(.system(size: 11.5)).foregroundStyle(.white.opacity(detailOpacity))
                }
                StopProgressBar(done: snapshot.doneCount, total: snapshot.stops.count)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading) {
                WidgetCaption(text: "Spent today").foregroundStyle(.white.opacity(captionOpacity))
                Text(snapshot.spentToday)
                    .font(.system(size: 20, weight: .bold))
                    .minimumScaleFactor(0.7)
                Spacer()
                Link(destination: WidgetLinks.addExpense) {
                    Label("Expense", systemImage: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.widgetNight)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(.white, in: .capsule)
                }
            }
            .frame(width: 104)
        }
    }

    private func countdownView(snapshot: TodaySnapshot, countdown: String) -> some View {
        VStack(alignment: .leading) {
            WidgetCaption(text: snapshot.tripTitle).foregroundStyle(.white.opacity(captionOpacity))
            Spacer()
            Text("Starts in").font(.system(size: 12)).foregroundStyle(.white.opacity(detailOpacity))
            Text(countdown)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
