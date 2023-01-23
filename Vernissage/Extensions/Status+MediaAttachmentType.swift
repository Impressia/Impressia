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
            status.mediaAttachments.contains { mediaAttachment in
                mediaAttachment.type == .image
            }
        }
    }
}
