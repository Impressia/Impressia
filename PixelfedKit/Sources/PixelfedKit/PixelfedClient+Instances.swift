//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension PixelfedClient {
    func readInstanceInformation() async throws -> Instance {
        let request = try Self.request(for: baseURL, target: Pixelfed.Instances.instance, timeoutInterval: 5)
        return try await downloadJson(Instance.self, request: request)
    }
}
