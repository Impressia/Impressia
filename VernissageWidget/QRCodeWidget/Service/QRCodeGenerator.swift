//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import QRCode

public class QRCodeGenerator {
    public static let shared = QRCodeGenerator()
    private init() { }

    func generateQRCode(from string: String, scheme: ColorScheme) -> UIImage? {
        let qrCode = QRCode(string: string,
                            color: scheme == .light ? Color.black.toUIColor() : Color.white.toUIColor(),
                            backgroundColor: scheme == .light ? Color.white.toUIColor() : Color.black.toUIColor(),
                            size: CGSize(width: 150, height: 150),
                            scale: 4.0,
                            inputCorrection: .medium)
        return try? qrCode?.image()
    }
}
