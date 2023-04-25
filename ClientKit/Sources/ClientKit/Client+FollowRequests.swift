//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension Client {
    public class FollowRequests: BaseClient {
        public func followRequests(limit: Int = 10,
                                   page: Int? = nil) async throws -> [Account] {
            return try await pixelfedClient.followRequests(limit: limit, page: page)
        }

        public func authorizeRequest(id: EntityId) async throws -> Relationship {
            return try await pixelfedClient.authorizeRequest(id: id)
        }

        public func rejectRequest(id: EntityId) async throws -> Relationship {
            return try await pixelfedClient.rejectRequest(id: id)
        }
    }
}
