//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public class PhotoUrl: ObservableObject, Identifiable {
    public var id: String

    @Published public var statusId: String?
    @Published public var url: URL?
    @Published public var blurhash: String?
    @Published public var sensitive = false
    
    init(id: String) {
        self.id = id
    }
}
