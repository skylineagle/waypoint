import ImageIO
import UIKit
import WidgetKit

enum WidgetPhotos {
    static func name(for place: StopPlace, trip: Trip) -> String? {
        guard let client = TrekClient.current else { return nil }
        let source = place.imageUrl ?? "\(place.googlePlaceId ?? place.osmId ?? "")|\(place.lat?.description ?? "")|\(place.lng?.description ?? "")|\(place.name)"
        return WidgetPhotoStore.name(for: "\(client.account.serverURL)|\(trip.id)|\(place.id)|\(source)")
    }

    static func coverName(for trip: Trip) -> String? {
        guard let cover = trip.coverImage, !cover.isEmpty, let client = TrekClient.current else { return nil }
        return WidgetPhotoStore.name(for: "\(client.account.serverURL)|\(trip.id)|\(cover)")
    }

    static func prepare(trip: Trip, stops: [TripStop], snapshot: TodaySnapshot) async {
        guard AppSettings.isWidgetPhotosEnabled, let client = TrekClient.current else { return }
        let names = snapshot.stops.compactMap(\.photoName) + [snapshot.coverPhotoName].compactMap(\.self)
        WidgetPhotoStore.keep(names)
        if snapshot.countdown != nil {
            if let name = snapshot.coverPhotoName, let cover = trip.coverImage {
                await cache(cover, named: name, client: client)
            }
            return
        }
        for stop in stops where !snapshot.doneIDs.contains(stop.id) {
            guard !Task.isCancelled, AppSettings.isWidgetPhotosEnabled else { return }
            guard let name = snapshot.stops.first(where: { $0.id == stop.id })?.photoName,
                  WidgetPhotoStore.load(name) == nil
            else { continue }
            let uploaded = stop.place.imageUrl.flatMap { $0.isEmpty ? nil : $0 }
            let path = if let uploaded { uploaded } else { try? await client.photo(of: stop.place) }
            if let path {
                await cache(path, named: name, client: client)
                if name == snapshot.photoName, !Task.isCancelled {
                    WidgetCenter.shared.reloadTimelines(ofKind: "NextStopWidget")
                }
            }
        }
    }

    private static func cache(_ path: String, named name: String, client: TrekClient) async {
        guard WidgetPhotoStore.load(name) == nil,
              let data = try? await client.image(at: path),
              !Task.isCancelled, AppSettings.isWidgetPhotosEnabled,
              Account.load()?.serverURL == client.account.serverURL,
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 800,
              ] as CFDictionary),
              let jpeg = UIImage(cgImage: thumbnail).jpegData(compressionQuality: 0.8)
        else { return }
        try? WidgetPhotoStore.save(jpeg, named: name)
    }
}
