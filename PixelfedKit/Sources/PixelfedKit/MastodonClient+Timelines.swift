//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension MastodonClientAuthenticated {
     func getHomeTimeline(
        maxId: EntityId? = nil,
        sinceId: EntityId? = nil,
        minId: EntityId? = nil,
        limit: Int? = nil) async throws -> [Status] {

        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Timelines.home(maxId, sinceId, minId, limit),
            withBearerToken: token
        )
                    
        return try await downloadJson([Status].self, request: request)
    }

    func getPublicTimeline(local: Bool = false,
                           remote: Bool = false,
                           onlyMedia: Bool = true,
                           maxId: EntityId? = nil,
                           sinceId: EntityId? = nil,
                           minId: EntityId? = nil,
                           limit: Limit? = nil) async throws -> [Status] {

        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Timelines.pub(local, remote, onlyMedia, maxId, sinceId, minId, limit),
            withBearerToken: token
        )
        
        
        return try await downloadJson([Status].self, request: request)
    }

    func getTagTimeline(tag: String,
                        local: Bool = false,
                        remote: Bool = false,
                        onlyMedia: Bool = true,
                        maxId: EntityId? = nil,
                        sinceId: EntityId? = nil,
                        minId: EntityId? = nil,
                        limit: Int? = nil) async throws -> [Status] {

        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Timelines.tag(tag, local, remote, onlyMedia, maxId, sinceId, minId, limit),
            withBearerToken: token
        )
        
        return try await downloadJson([Status].self, request: request)
    }

    func setMarkers(_ markers: [Mastodon.Markers.Timeline: EntityId]) async throws -> Markers {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Markers.set(markers),
            withBearerToken: token
        )

        return try await downloadJson(Markers.self, request: request)
    }

    func readMarkers(_ markers: Set<Mastodon.Markers.Timeline>) async throws -> Markers {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Markers.read(markers),
            withBearerToken: token
        )

        return try await downloadJson(Markers.self, request: request)
    }
}
