//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ImageCarouselPicture: View {
    @ObservedObject public var attachment: AttachmentModel
    
    private let onImageDownloaded: (AttachmentModel, Data) -> Void
    
    init(attachment: AttachmentModel, onImageDownloaded: @escaping (_: AttachmentModel, _: Data) -> Void) {
        self.attachment = attachment
        self.onImageDownloaded = onImageDownloaded
    }
    
    var body: some View {
        if let data = attachment.data, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            BlurredImage(blurhash: attachment.blurhash)
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
