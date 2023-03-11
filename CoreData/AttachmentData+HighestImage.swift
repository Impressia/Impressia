//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

extension [AttachmentData] {
    func getHighestImage() -> AttachmentData? {
        var attachment = self.first
        var imgHeight = 0.0

        for item in self {
            let attachmentheight = Double(item.metaImageHeight)
            if attachmentheight > imgHeight {
                attachment = item
                imgHeight = attachmentheight
            }
        }
        
        return attachment
    }
}
