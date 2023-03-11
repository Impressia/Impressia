//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension AttachmentData : Comparable {
    public static func < (lhs: AttachmentData, rhs: AttachmentData) -> Bool {
        lhs.id < rhs.id
    }
}
