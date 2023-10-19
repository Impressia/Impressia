//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

@Observable public class PhotoUrl: Identifiable {
    public var id: String

    public var statusId: String?
    public var url: URL?
    public var blurhash: String?
    public var sensitive = false

    init(id: String) {
        self.id = id
    }
}
