//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension AttachmentData : Comparable {
    public static func < (lhs: AttachmentData, rhs: AttachmentData) -> Bool {
        lhs.id < rhs.id
    }
}
