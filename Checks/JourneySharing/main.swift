import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func check(_ condition: @autoclosure () throws -> Bool) rethrows {
    let result = try condition()
    assert(result)
}

let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
defer { try? FileManager.default.removeItem(at: directory) }
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
let source = directory.appending(path: "source.jpg")
let bytes = Data([0xff, 0xd8, 0xff, 0xe0, 1, 2, 3])
try bytes.write(to: source)
let store = JourneyStore(directory: directory.appending(path: "queue"))
let session = JourneySession(serverURL: URL(string: "https://trek.example.com/subpath/")!, email: "person@example.com", token: "fixture", tripID: 7, tripTitle: "Japan")
let destination = JourneyDestination(id: 12, title: "Autumn in Japan", tripID: 7, tripTitle: "Japan", scope: session.scope, knownPhotoIDs: [31])
let batch = try store.enqueue([source, source], destination: destination)
try check(store.list().count == 1)
assert(batch.photos.count == 2)
try check(Data(contentsOf: store.file(batch.photos[0], upload: batch.id)) == bytes)
let multipart = try Data(contentsOf: store.body(batch.photos[0], upload: batch.id))
assert(String(decoding: multipart, as: UTF8.self).contains("name=\"photos\""))
assert(multipart.range(of: bytes) != nil)
try store.update(batch.id) { $0.photos[0].state = .uncertain }
let persisted = try JourneyStore(directory: store.directory).list()[0]
assert(persisted.photos[0].state == .uncertain)
assert(persisted.destination.tripID == 7)
assert(persisted.destination.knownPhotoIDs == [31])
assert(JourneyStore.result(status: 201, confirmed: true, error: false) == nil)
assert(JourneyStore.result(status: 201, confirmed: false, error: false) == .uncertain)
assert(JourneyStore.result(status: 0, confirmed: false, error: true) == .uncertain)
assert(JourneyStore.result(status: 500, confirmed: false, error: false) == .uncertain)
assert(JourneyStore.result(status: 401, confirmed: false, error: false) == .signIn)
assert(JourneyStore.result(status: 403, confirmed: false, error: false) == .failed)
assert(JourneyStore.result(status: 413, confirmed: false, error: false) == .failed)
assert(JourneyStore.result(status: 408, confirmed: false, error: false) == .uncertain)
try check(JourneyStore.request("api/journeys/12/gallery/photos", session: session).url?.absoluteString == "https://trek.example.com/subpath/api/journeys/12/gallery/photos")
do {
    _ = try JourneyStore.request("https://another.example.com/api/journeys", session: session)
    assertionFailure("Session credentials must not be sent to another host")
} catch { }
let tooLarge = directory.appending(path: "large.jpg")
try Data(repeating: 0, count: 20 * 1024 * 1024 + 1).write(to: tooLarge)
do {
    _ = try store.enqueue([source, tooLarge], destination: destination)
    assertionFailure("Oversized photos must reject the entire batch")
} catch { }
try check(store.list().count == 1)
try store.update(batch.id) { $0.photos.removeFirst() }
try check(store.list()[0].photos.count == 1)
try store.update(batch.id) { $0.photos.removeAll() }
try check(store.list().isEmpty)

let imageBytes = Data(repeating: 128, count: 4 * 4 * 4)
let provider = CGDataProvider(data: imageBytes as CFData)!
let image = CGImage(width: 4, height: 4, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 16,
                    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
                    provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
let heic = directory.appending(path: "source.heic")
let imageWriter = CGImageDestinationCreateWithURL(heic as CFURL, UTType.heic.identifier as CFString, 1, nil)!
let metadata = [
    kCGImagePropertyExifDictionary: [kCGImagePropertyExifDateTimeOriginal: "2026:09:27 14:30:00"],
    kCGImagePropertyGPSDictionary: [kCGImagePropertyGPSLatitude: 35.68, kCGImagePropertyGPSLongitude: 139.76],
] as CFDictionary
CGImageDestinationAddImage(imageWriter, image, metadata)
assert(CGImageDestinationFinalize(imageWriter))
let jpeg = try JourneyPhoto.prepare(heic, in: directory)
let normalized = CGImageSourceCreateWithURL(jpeg as CFURL, nil)!
let properties = CGImageSourceCopyPropertiesAtIndex(normalized, 0, nil)! as NSDictionary
let exif = properties[kCGImagePropertyExifDictionary] as! NSDictionary
let gps = properties[kCGImagePropertyGPSDictionary] as! NSDictionary
assert(exif[kCGImagePropertyExifDateTimeOriginal] as? String == "2026:09:27 14:30:00")
assert(gps[kCGImagePropertyGPSLatitude] as? Double == 35.68)
assert(gps[kCGImagePropertyGPSLongitude] as? Double == 139.76)
try check(Data(contentsOf: JourneyPhoto.prepare(jpeg, in: directory)) == Data(contentsOf: jpeg))
print("Journey sharing checks passed")

func stop(_ id: Int, _ date: String, _ lat: Double?, _ lng: Double?) -> JourneyStop {
    JourneyStop(id: id, entryDate: date, entryTime: nil, title: "Stop \(id)", locationName: nil, locationLat: lat, locationLng: lng)
}
let stops = [stop(1, "2025-10-03", 35.7148, 139.7967), stop(2, "2025-10-03", 35.6595, 139.7005), stop(3, "2025-10-04", 35.7148, 139.7967)]
assert(JourneyStop.nearest(to: .init(day: "2025-10-03", latitude: 35.7150, longitude: 139.7970), in: stops)?.id == 1)
assert(JourneyStop.nearest(to: .init(day: "2025-10-04", latitude: 35.7150, longitude: 139.7970), in: stops)?.id == 3)
assert(JourneyStop.nearest(to: .init(day: "2025-10-03", latitude: 35.0, longitude: 135.0), in: stops) == nil)
assert(JourneyStop.nearest(to: .init(day: "2025-10-03", latitude: nil, longitude: nil), in: stops) == nil)
assert(JourneyStop.nearest(to: .init(day: "2025-10-05", latitude: 35.7150, longitude: 139.7970), in: stops) == nil)
