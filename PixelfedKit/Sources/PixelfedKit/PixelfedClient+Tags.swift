//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension PixelfedClientAuthenticated {

    func tag(hashtag: String) async throws -> Tag {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Tags.tag(hashtag),
            withBearerToken: token
        )

        return try await downloadJson(Tag.self, request: request)
    }

    func follow(hashtag: String) async throws -> Tag {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Tags.follow(hashtag),
            withBearerToken: token
        )

        return try await downloadJson(Tag.self, request: request)
    }

    func unfollow(hashtag: String) async throws -> Tag {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Tags.unfollow(hashtag),
            withBearerToken: token
        )

        return try await downloadJson(Tag.self, request: request)
    }
    
    func followedTags(maxId: MaxId? = nil,
                      sinceId: SinceId? = nil,
                      minId: MinId? = nil,
                      limit: Int? = nil
    ) async throws -> Linkable<[Tag]> {
        let request = try Self.request(for: baseURL,
                                       target: Pixelfed.Tags.followed(maxId, sinceId, minId, limit),
                                       withBearerToken: token)

        return try await downloadJsonWithLink([Tag].self, request: request)
    }
}
