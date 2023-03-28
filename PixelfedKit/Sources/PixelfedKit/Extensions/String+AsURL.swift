//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension String {
    func asURL() -> URL? {
        return URL(string: self)
    }
}

extension String {
    static let showTimeline = "ShowTimeline"
}
