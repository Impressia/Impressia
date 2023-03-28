//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import SwiftUI

extension UIImage {
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))

        let format = imageRendererFormat
        format.opaque = isOpaque

        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func resized(toHeight height: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: CGFloat(ceil(height/size.height * size.width)), height: height)

        let format = imageRendererFormat
        format.opaque = isOpaque

        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
