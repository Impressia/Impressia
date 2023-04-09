//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension PixelfedClientAuthenticated {
    func mutes(maxId: EntityId? = nil,
               sinceId: EntityId? = nil,
               minId: EntityId? = nil,
               limit: Int? = nil,
               page: Page? = nil) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Mutes.mutes(maxId, sinceId, minId, limit, page),
            withBearerToken: token
        )

        return try await downloadJson([Account].self, request: request)
    }
}
