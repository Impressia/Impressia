//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension MastodonClientAuthenticated {

    func tag(hashtag: String) async throws -> Tag {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Tags.tag(hashtag),
            withBearerToken: token
        )
        
        return try await downloadJson(Tag.self, request: request)
    }
    
    func follow(hashtag: String) async throws -> Tag {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Tags.follow(hashtag),
            withBearerToken: token
        )
        
        return try await downloadJson(Tag.self, request: request)
    }
    
    func unfollow(hashtag: String) async throws -> Tag {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Tags.unfollow(hashtag),
            withBearerToken: token
        )
        
        return try await downloadJson(Tag.self, request: request)
    }
}
