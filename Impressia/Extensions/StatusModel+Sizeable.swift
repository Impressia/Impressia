//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import ClientKit

extension StatusModel: Sizable {
    public var height: Double {
        return Double(self.mediaAttachments.first?.metaImageHeight ?? 500)
    }

    public var width: Double {
        return Double(self.mediaAttachments.first?.metaImageWidth ?? 500)
    }
}
