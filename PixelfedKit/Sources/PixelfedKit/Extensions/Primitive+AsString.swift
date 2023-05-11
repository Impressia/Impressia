//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Bool {
    var asString: String {
        return self == true ? "1" : "0"
    }
}

extension Int {
    var asString: String {
        return "\(self)"
    }
}
