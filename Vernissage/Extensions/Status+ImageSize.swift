//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonSwift

extension Status {
    public func getImageWidth() -> Int32? {
        if let width = (self.mediaAttachments.first?.meta as? ImageMetadata)?.original?.width {
            return Int32(width)
        } else {
            return nil
        }
    }
    
    public func getImageHeight() -> Int32? {
        if let height = (self.mediaAttachments.first?.meta as? ImageMetadata)?.original?.height {
            return Int32(height)
        } else {
            return nil
        }
    }
}
