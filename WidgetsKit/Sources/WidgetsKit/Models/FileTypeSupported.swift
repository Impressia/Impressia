//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import AVFoundation
import Foundation
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import ServicesKit

@MainActor
enum FileTypeSupported: String, CaseIterable {
    case image = "public.image"
    case jpeg = "public.jpeg"
    case png = "public.png"
    case tiff = "public.tiff"
    case gif = "public.gif"

    case gif2 = "com.compuserve.gif"
    case adobeRawImage = "com.adobe.raw-image"
    case uiimage = "com.apple.uikit.image"

    public nonisolated static var allCases: [FileTypeSupported] {
        [.image, .jpeg, .png, .tiff, .gif, .gif2, .uiimage, .adobeRawImage]
    }

    func loadItemContent(item: NSItemProvider) async throws -> TransferedFile? {
        let result = try await item.loadItem(forTypeIdentifier: rawValue)

        if isImageFile() {
            if let image = result as? UIImage,
               let data = image.getJpegData() {
                let fileUrl = getTmpFileUrl()
                try data.write(to: fileUrl)

                return TransferedFile(file: data, url: fileUrl)
            } else if let imageURL = result as? URL,
                      let data = await ImageCompressService.shared.compressImageFrom(url: imageURL) {
                let fileUrl = getTmpFileUrl()
                try data.write(to: fileUrl)

                return TransferedFile(file: data, url: fileUrl)
            } else if let data = result as? Data {
                let fileUrl = getTmpFileUrl()
                try data.write(to: fileUrl)

                return TransferedFile(file: data, url: fileUrl)
            }
        }

        if let transferable = try await item.createImageFileTranseferable(),
           let data = await ImageCompressService.shared.compressImageFrom(url: transferable.url) {
            return TransferedFile(file: data, url: transferable.url)
        }

        if let image = result as? UIImage,
           let data = image.getJpegData() {
            let fileUrl = getTmpFileUrl()
            try data.write(to: fileUrl)

            return TransferedFile(file: data, url: fileUrl)
        }

        return nil
    }

    func isImageFile() -> Bool {
        return self == .jpeg || self == .png || self == .tiff || self == .image || self == .uiimage || self == .adobeRawImage
    }

    func getTmpFileUrl() -> URL {
        return URL.temporaryDirectory.appending(path: "\(UUID().uuidString).jpg")
    }
}
