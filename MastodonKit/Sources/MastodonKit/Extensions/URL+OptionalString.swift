//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
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
