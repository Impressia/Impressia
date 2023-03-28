//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import UIKit

extension UIImage.Orientation {
    var exifOrientation: Int32 {
        switch self {
        case .up: return 1
        case .down: return 3
        case .left: return 8
        case .right: return 6
        case .upMirrored: return 2
        case .downMirrored: return 4
        case .leftMirrored: return 5
        case .rightMirrored: return 7
        @unknown default: return 1
        }
    }
}

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        guard let sourceImage = CIImage(image: self, options: [.applyOrientationProperty: true]) else {
            return self
        }
        
        // We have to store correct image orientation.
        let orientedImage = sourceImage.oriented(forExifOrientation: self.imageOrientation.exifOrientation)
        
        // Filter.
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")!
        
        // Compute scale.
        let scale = targetSize.width / orientedImage.extent.width

        // Apply resizing
        resizeFilter.setValue(orientedImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(1.0, forKey: kCIInputAspectRatioKey)

        guard let result = resizeFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            return self
        }

        guard let resizedCGImage = CIContext(options: nil).createCGImage(result, from: result.extent) else {
            return self
        }
        
        return UIImage(cgImage: resizedCGImage)
    }
}
