//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    public static let shared = QRCodeGenerator()
    private init() { }
    
    let context = CIContext()

    func generateQRCode(from text: String) -> UIImage? {
        let filter  = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return nil
    }
}
