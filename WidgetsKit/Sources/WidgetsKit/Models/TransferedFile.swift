//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public struct TransferedFile {
    public let file: Data
    public let url: URL

    public init(file: Data, url: URL) {
        self.file = file
        self.url = url
    }
}
