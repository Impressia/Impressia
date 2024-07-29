//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ClientKit
import ServicesKit
import WidgetsKit

struct ImageCarouselPicture: View {
    public var attachment: AttachmentModel

    @State private var blurredImageHeight: Double
    @State private var blurredImageWidth: Double

    private let onImageDownloaded: (AttachmentModel, Data) -> Void

    init(attachment: AttachmentModel, onImageDownloaded: @escaping (_: AttachmentModel, _: Data) -> Void) {
        self.attachment = attachment
        self.onImageDownloaded = onImageDownloaded

        if let size = ImageSizeService.shared.get(for: attachment.url) {
            let imageSize = ImageSizeService.shared.calculate(width: size.width, height: size.height)

            self.blurredImageHeight = imageSize.height
            self.blurredImageWidth = imageSize.width
        } else if let imageWidth = attachment.metaImageWidth, let imageHeight = attachment.metaImageHeight {
            let imageSize = ImageSizeService.shared.calculate(width: Double(imageWidth), height: Double(imageHeight))

            self.blurredImageHeight = imageSize.height
            self.blurredImageWidth = imageSize.width
        } else {
            self.blurredImageHeight = 100.0
            self.blurredImageWidth = 100.0
        }
    }

    var body: some View {
        if let data = attachment.data, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            BlurredImage(blurhash: attachment.blurhash)
                .frame(width: self.blurredImageWidth, height: self.blurredImageHeight)
                .task {
                    do {
                        // Download image and recalculate exif data.
                        if let imageData = try await RemoteFileService.shared.fetchData(url: attachment.url) {
                            self.onImageDownloaded(attachment, imageData)
                        }
                    } catch {
                        ErrorService.shared.handle(error, message: "global.error.errorDuringImageDownload")
                    }
                }
        }
    }
}
