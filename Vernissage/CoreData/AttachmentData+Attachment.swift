//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonKit

extension AttachmentData {
    func copyFrom(_ attachment: MediaAttachment) {
        self.id = attachment.id
        self.url = attachment.url
        self.blurhash = attachment.blurhash
        self.previewUrl = attachment.previewUrl
        self.remoteUrl = attachment.remoteUrl
        self.text = attachment.description
        self.type = attachment.type.rawValue
        
        // We can set image width only when it wasn't previusly recalculated.
        if let width = (attachment.meta as? ImageMetadata)?.original?.width, self.metaImageWidth <= 0 && width > 0 {
            self.metaImageWidth = Int32(width)
        }
        
        // We can set image height only when it wasn't previusly recalculated.
        if let height = (attachment.meta as? ImageMetadata)?.original?.height, self.metaImageHeight <= 0 && height > 0 {
            self.metaImageHeight = Int32(height)
        }
    }
}
