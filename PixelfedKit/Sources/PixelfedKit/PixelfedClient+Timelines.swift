//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension PixelfedClientAuthenticated {
     func getHomeTimeline(
        maxId: EntityId? = nil,
        sinceId: EntityId? = nil,
        minId: EntityId? = nil,
        limit: Int? = nil) async throws -> [Status] {

        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Timelines.home(maxId, sinceId, minId, limit),
            withBearerToken: token
        )

        return try await downloadJson([Status].self, request: request)
    }

    func getPublicTimeline(local: Bool? = nil,
                           remote: Bool? = nil,
                           onlyMedia: Bool = true,
                           maxId: EntityId? = nil,
                           sinceId: EntityId? = nil,
                           minId: EntityId? = nil,
                           limit: Limit? = nil) async throws -> [Status] {

        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Timelines.pub(local, remote, onlyMedia, maxId, sinceId, minId, limit),
            withBearerToken: token
        )

        return try await downloadJson([Status].self, request: request)
    }

    func getTagTimeline(tag: String,
                        local: Bool? = nil,
                        remote: Bool? = nil,
                        onlyMedia: Bool = true,
                        maxId: EntityId? = nil,
                        sinceId: EntityId? = nil,
                        minId: EntityId? = nil,
                        limit: Int? = nil) async throws -> [Status] {

        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Timelines.tag(tag, local, remote, onlyMedia, maxId, sinceId, minId, limit),
            withBearerToken: token
        )

        return try await downloadJson([Status].self, request: request)
    }

    func setMarkers(_ markers: [Pixelfed.Markers.Timeline: EntityId]) async throws -> Markers {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Markers.set(markers),
            withBearerToken: token
        )

        return try await downloadJson(Markers.self, request: request)
    }

    func readMarkers(_ markers: Set<Pixelfed.Markers.Timeline>) async throws -> Markers {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Markers.read(markers),
            withBearerToken: token
        )

        return try await downloadJson(Markers.self, request: request)
    }
}
