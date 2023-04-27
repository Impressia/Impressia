//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension PixelfedClientAuthenticated {
    func followRequests(limit: Int? = nil,
                        page: Page? = nil) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.FollowRequests.followRequests(limit, page),
            withBearerToken: token
        )

        return try await downloadJson([Account].self, request: request)
    }

    func authorizeRequest(id: EntityId) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.FollowRequests.authorize(id),
            withBearerToken: token
        )

        return try await downloadJson(Relationship.self, request: request)
    }

    func rejectRequest(id: EntityId) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.FollowRequests.reject(id),
            withBearerToken: token
        )

        return try await downloadJson(Relationship.self, request: request)
    }
}
