//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension PixelfedClientAuthenticated {
    func boost(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.reblog(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unboost(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.unreblog(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func bookmark(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.bookmark(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unbookmark(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.unbookmark(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func favourite(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.favourite(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unfavourite(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.unfavourite(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func pin(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.pin(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unpin(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.unpin(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func new(statusComponents: Pixelfed.Statuses.Components) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.new(statusComponents),
            withBearerToken: token)

        return try await downloadJson(Status.self, request: request)
    }

    func delete(statusId: EntityId) async throws {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.delete(statusId),
            withBearerToken: token)

        try await send(request: request)
    }
}
