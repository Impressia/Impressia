//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import PixelfedKit

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
            return reblog.mediaAttachments
                .sorted(by: { (lhs, rhs) in lhs.id < rhs.id })
                .filter { mediaAttachment in mediaAttachment.type == .image }
        }
        
        return self.mediaAttachments
            .sorted(by: { (lhs, rhs) in lhs.id < rhs.id })
            .filter { mediaAttachment in mediaAttachment.type == .image }
    }
}
