//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

extension UIImage {
    public func getJpegData() -> Data? {
#if targetEnvironment(simulator)
        // For testing purposes.
        let converted = self.convertToExtendedSRGBJpeg()
        let filePath = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).jpg")
        try? converted?.write(to: filePath)
        print(filePath.string)
#endif
        
        // API don't support images over 5K.
        if self.size.height > 10_000 || self.size.width > 10_000 {
            return self
                .resized(to: .init(width: self.size.width / 4, height: self.size.height / 4))
                .convertToExtendedSRGBJpeg()
        } else if self.size.height > 5000 || self.size.width > 5000 {
            return self
                .resized(to: .init(width: self.size.width / 2, height: self.size.height / 2))
                .convertToExtendedSRGBJpeg()
        } else {
            return self
                .convertToExtendedSRGBJpeg()
        }
    }
    
    public func convertToExtendedSRGBJpeg() -> Data? {
        guard let sourceImage = CIImage(image: self, options: [.applyOrientationProperty: true]) else {
            return self.jpegData(compressionQuality: 0.9)
        }
        
        // We have to store correct image orientation.
        let orientedImage = sourceImage.oriented(forExifOrientation: self.imageOrientation.exifOrientation)
        
        // We dont have to convert images which already are in sRGB color space.
        if orientedImage.colorSpace?.name == CGColorSpace.sRGB || orientedImage.colorSpace?.name == CGColorSpace.extendedSRGB {
            return self.jpegData(compressionQuality: 0.9)
        }
                
        guard let colorSpace = CGColorSpace(name: CGColorSpace.extendedSRGB) else {
            return self.jpegData(compressionQuality: 0.9)
        }

        guard let displayP3 = CGColorSpace(name: CGColorSpace.displayP3) else {
            return self.jpegData(compressionQuality: 0.9)
        }

        // Create Core Image context (with working color space).
        let ciContext = CIContext(options: [CIContextOption.workingColorSpace: orientedImage.colorSpace ?? displayP3])
        
        // Creating image with new color space (and preserving colors).
        guard let converted = ciContext.jpegRepresentation(of: orientedImage, colorSpace: colorSpace) else {
            return self.jpegData(compressionQuality: 0.9)
        }
        
        // Returning successfully converted image.
        return converted
    }
}
