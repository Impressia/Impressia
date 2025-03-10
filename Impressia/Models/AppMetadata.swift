//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

public struct AppMetadata: Codable {
    public let instructionsUrl: String
    public let serversUrl: String
    public let instances: [Instance]

    init() {
        self.instructionsUrl = "https://pixelfed.org/how-to-join"
        self.serversUrl = "https://pixelfed.org/servers"
        self.instances = []
    }
}
