//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension Bool {
    var asString: String {
        return self == true ? "true" : "false"
    }
}

extension Int {
    var asString: String {
        return "\(self)"
    }
}
