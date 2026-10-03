import Photos
import UIKit
import UniformTypeIdentifiers

enum RecapLibrary {
    static func requestAccess() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status == .authorized || status == .limited
    }

    static func assets(from start: Date, to end: Date) -> [PHAsset] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d AND creationDate >= %@ AND creationDate < %@", PHAssetMediaType.image.rawValue, start as NSDate, end as NSDate)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssets(with: options)
        return (0..<result.count).map(result.object(at:)).filter { !$0.mediaSubtypes.contains(.photoScreenshot) }
    }

    static func thumbnail(of asset: PHAsset, side: CGFloat) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        let size = CGSize(width: side, height: side)
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    static func export(_ asset: PHAsset, to directory: URL) async throws -> URL {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.isNetworkAccessAllowed = true
        let (data, type): (Data?, String?) = await withCheckedContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, type, _, _ in
                continuation.resume(returning: (data, type))
            }
        }
        guard let data else { throw JourneyError.message("A photo couldn't be loaded from your library. It may still be downloading from iCloud.") }
        let fileExtension = type.flatMap { UTType($0)?.preferredFilenameExtension } ?? "heic"
        let raw = directory.appending(path: "\(UUID().uuidString).\(fileExtension)")
        try data.write(to: raw)
        defer { try? FileManager.default.removeItem(at: raw) }
        return try JourneyPhoto.prepare(raw, in: directory)
    }
}
