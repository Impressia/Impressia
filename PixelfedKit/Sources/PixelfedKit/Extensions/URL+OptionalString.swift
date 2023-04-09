//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension URL {
    static func fromOptional(string: String?) -> URL? {
        guard let string = string else {
            return nil
        }
        return URL(string: string)
    }
}
