import Foundation
import ImageIO
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#endif

nonisolated enum JourneyPhoto {
    struct Taken {
        let day: String?
        let latitude: Double?
        let longitude: Double?
    }

    static func taken(_ source: URL) -> Taken {
        let properties = CGImageSourceCreateWithURL(source as CFURL, nil)
            .flatMap { CGImageSourceCopyPropertiesAtIndex($0, 0, nil) as? [CFString: Any] } ?? [:]
        let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any]
        let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any]
        let day = (exif?[kCGImagePropertyExifDateTimeOriginal] as? String).map { String($0.prefix(10)).replacingOccurrences(of: ":", with: "-") }
        func coordinate(_ value: CFString, _ reference: CFString, negative: String) -> Double? {
            guard let magnitude = gps?[value] as? Double else { return nil }
            return (gps?[reference] as? String) == negative ? -magnitude : magnitude
        }
        return Taken(day: day,
                     latitude: coordinate(kCGImagePropertyGPSLatitude, kCGImagePropertyGPSLatitudeRef, negative: "S"),
                     longitude: coordinate(kCGImagePropertyGPSLongitude, kCGImagePropertyGPSLongitudeRef, negative: "W"))
    }

    static func prepare(_ source: URL, in directory: URL) throws -> URL {
        guard let image = CGImageSourceCreateWithURL(source as CFURL, nil),
              let type = CGImageSourceGetType(image) else { throw JourneyError.message("One of these files isn't a readable photo.") }
        let originalType = type as String
        let keepOriginal = originalType == UTType.jpeg.identifier || originalType == UTType.png.identifier
        let file = directory.appending(path: "\(UUID().uuidString).\(originalType == UTType.png.identifier ? "png" : "jpg")")
        if keepOriginal {
            try FileManager.default.copyItem(at: source, to: file)
        } else {
            guard let destination = CGImageDestinationCreateWithURL(file as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
                throw JourneyError.message("Couldn't prepare this photo.")
            }
            let properties = [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary
            CGImageDestinationAddImageFromSource(destination, image, 0, properties)
            guard CGImageDestinationFinalize(destination) else { throw JourneyError.message("Couldn't convert this photo to JPEG.") }
        }
        let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size > 0, size <= 20 * 1024 * 1024 else {
            try? FileManager.default.removeItem(at: file)
            throw JourneyError.message("Each photo must be smaller than 20 MB. Choose a smaller copy of this photo.")
        }
        return file
    }

    #if canImport(UIKit)
    static func thumbnail(_ file: URL) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(file as CFURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 240,
              ] as CFDictionary) else { return nil }
        return UIImage(cgImage: image)
    }
    #endif
}
