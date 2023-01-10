//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation
import MastodonKit

extension AttachmentData {
    func copyFrom(_ attachment: Attachment) {
        self.id = attachment.id
        self.url = attachment.url
        self.blurhash = attachment.blurhash
        self.previewUrl = attachment.previewUrl
        self.remoteUrl = attachment.remoteUrl
        self.text = attachment.description
        self.type = attachment.type.rawValue
        
        if let width = (attachment.meta as? ImageMetadata)?.original?.width {
            self.metaImageWidth = Int32(width)
        }
        
        if let height = (attachment.meta as? ImageMetadata)?.original?.height {
            self.metaImageHeight = Int32(height)
        }
    }
}
