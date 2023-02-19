//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import PixelfedKit

/// Mastodon 'Account'.
extension Client {
    public class Accounts: BaseClient {
        
        public func account(withId accountId: String) async throws -> Account? {
            return try await mastodonClient.account(for: accountId)
        }
        
        public func relationships(withId accountId: String) async throws -> Relationship? {
            return try await mastodonClient.relationships(for: accountId)
        }
        
        public func statuses(createdBy accountId: String,
                             onlyMedia: Bool = true,
                             excludeReplies: Bool = true,
                             maxId: String? = nil,
                             sinceId: String? = nil,
                             minId: String? = nil,
                             limit: Int = 40) async throws -> [Status] {
            return try await mastodonClient.statuses(for: accountId,
                                             onlyMedia: onlyMedia,
                                             excludeReplies: excludeReplies,
                                             maxId: maxId,
                                             sinceId: sinceId,
                                             minId: minId,
                                             limit: limit)
        }
        
        public func follow(account accountId: String) async throws -> Relationship? {
            return try await mastodonClient.follow(for: accountId)
        }
        
        public func unfollow(account accountId: String) async throws -> Relationship? {
            return try await mastodonClient.unfollow(for: accountId)
        }
        
        public func mute(account accountId: String) async throws -> Relationship? {
            return try await mastodonClient.mute(for: accountId)
        }
        
        public func unmute(account accountId: String) async throws -> Relationship? {
            return try await mastodonClient.unmute(for: accountId)
        }
        
        public func block(account accountId: String) async throws -> Relationship? {
            return try await mastodonClient.block(for: accountId)
        }
        
        public func unblock(account accountId: String) async throws -> Relationship? {
            return try await mastodonClient.unblock(for: accountId)
        }
        
        public func followers(account accountId: String, page: Int) async throws -> [Account] {
            return try await mastodonClient.followers(for: accountId, page: page)
        }
        
        public func following(account accountId: String, page: Int) async throws -> [Account] {
            return try await mastodonClient.following(for: accountId, page: page)
        }
        
        public func favourites(maxId: String? = nil,
                               sinceId: String? = nil,
                               minId: String? = nil,
                               limit: Int = 10,
                               page: Int? = nil) async throws -> [Status] {
            return try await mastodonClient.favourites(limit: limit, page: page)
        }
        
        public func bookmarks(maxId: String? = nil,
                              sinceId: String? = nil,
                              minId: String? = nil,
                              limit: Int = 10,
                              page: Int? = nil) async throws -> [Status] {
            return try await mastodonClient.bookmarks(limit: limit, page: page)
        }
    }
}
