import AppIntents
import SwiftUI

struct NextStopSnippet: View {
    let snapshot: TodaySnapshot
    let stop: TodaySnapshot.Stop

    private var tint: Color {
        stop.category?.tint ?? .trekIndigo
    }

    private var directionsURL: URL? {
        guard let latitude = stop.latitude, let longitude = stop.longitude else { return nil }
        return AppSettings.directionsApp.url(latitude: latitude, longitude: longitude)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: stop.category?.symbol ?? "mappin")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(tint, in: .rect(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Up next · \(snapshot.position) of \(snapshot.stops.count)")
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                    Text(stop.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
            }
            if let directionsURL {
                Button(intent: OpenURLIntent(directionsURL)) {
                    Label(stop.leg ?? "Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 12))
                .controlSize(.large)
                .tint(.trekIndigo)
            }
        }
        .padding()
    }
}
