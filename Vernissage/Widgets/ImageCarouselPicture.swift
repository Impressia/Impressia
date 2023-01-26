//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ImageCarouselPicture: View {
    @ObservedObject public var attachment: AttachmentViewModel
    
    private let onImageDownloaded: (AttachmentViewModel, Data) -> Void
    
    init(attachment: AttachmentViewModel, onImageDownloaded: @escaping (_: AttachmentViewModel, _: Data) -> Void) {
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
                        ErrorService.shared.handle(error, message: "Connot download image for status")
                    }
                }
        }
    }
}
