//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import AVFoundation
import UIKit

public class ImageCompressService {
    public static let shared = ImageCompressService()
    private init() { }

    public func compressImageFrom(url: URL) async -> Data? {
        return await withCheckedContinuation { continuation in
            let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary

            guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
                continuation.resume(returning: nil)
                return
            }

            let maxPixelSize: Int
            if Bundle.main.bundlePath.hasSuffix(".appex") {
                maxPixelSize = 2048
            } else {
                maxPixelSize = 4096
            }

            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
            ] as [CFString: Any] as CFDictionary

            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
                continuation.resume(returning: nil)
                return
            }

            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
                continuation.resume(returning: nil)
                return
            }

            let isPNG: Bool = {
                guard let utType = cgImage.utType else { return false }
                return (utType as String) == UTType.png.identifier
            }()

            let destinationProperties = [
                kCGImageDestinationLossyCompressionQuality: isPNG ? 1.0 : 0.85
            ] as CFDictionary

            CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
            CGImageDestinationFinalize(imageDestination)

            continuation.resume(returning: data as Data)
        }
    }
}
