//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension MastodonClientAuthenticated {
    func boost(statusId: EntityId) async throws -> Status {
        // TODO: Check whether the current user already boosted the status
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.reblog(statusId),
            withBearerToken: token
        )
                
        return try await downloadJson(Status.self, request: request)
    }
    
    func unboost(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.unreblog(statusId),
            withBearerToken: token
        )
        
        return try await downloadJson(Status.self, request: request)
    }

    func bookmark(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.bookmark(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unbookmark(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.unbookmark(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func favourite(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.favourite(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unfavourite(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.unfavourite(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }
    
    func pin(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.pin(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unpin(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.unpin(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func new(statusComponents: Mastodon.Statuses.Components) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.new(statusComponents),
            withBearerToken: token)

        return try await downloadJson(Status.self, request: request)
    }
    
    func delete(statusId: EntityId) async throws {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.delete(statusId),
            withBearerToken: token)

        try await send(request: request)
    }
}
