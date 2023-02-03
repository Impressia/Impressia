//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

/// Mastodon 'Tags'.
extension Client {
    public class Tags: BaseClient {
        public func get(tag: String) async throws -> Tag? {
            return try await mastodonClient.tag(hashtag: tag)
        }
        
        public func follow(tag: String) async throws -> Tag? {
            return try await mastodonClient.follow(hashtag: tag)
        }
        
        public func unfollow(tag: String) async throws -> Tag? {
            return try await mastodonClient.unfollow(hashtag: tag)
        }
    }
}
