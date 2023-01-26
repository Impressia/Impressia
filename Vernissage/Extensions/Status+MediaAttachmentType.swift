//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

extension [Status] {
    func getStatusesWithImagesOnly() -> [Status] {
        return self.filter { status in
            status.statusContainsImage()
        }
    }
}

extension Status {
    func statusContainsImage() -> Bool {
        return getAllImageMediaAttachments().isEmpty == false
    }
    
    func getAllImageMediaAttachments() -> [MediaAttachment] {
        if let reblog = self.reblog {
            // If status is rebloged the we have to check if orginal status contains image.
            return reblog.mediaAttachments.filter { mediaAttachment in mediaAttachment.type == .image }
        }
        
        return self.mediaAttachments.filter { mediaAttachment in mediaAttachment.type == .image }
    }
}
