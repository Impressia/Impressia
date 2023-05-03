//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension StatusData {
    func isFaulty() -> Bool {
        return self.isDeleted || self.isFault
    }
}
