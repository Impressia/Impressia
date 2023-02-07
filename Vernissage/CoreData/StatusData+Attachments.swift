//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension StatusData {
    func attachments() -> [AttachmentData] {
        guard let attachments = self.attachmentsRelation else {
            return []
        }

        return attachments.sorted(by: { lhs, rhs in
            lhs.id < rhs.id
        })
    }
}
