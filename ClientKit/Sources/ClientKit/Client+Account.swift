//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension Client {
    public class Accounts: BaseClient {

        public func account(withId accountId: String) async throws -> Account? {
            return try await pixelfedClient.account(for: accountId)
        }

        public func relationships(withId accountId: String) async throws -> Relationship? {
            return try await pixelfedClient.relationships(for: accountId)
        }

        public func statuses(createdBy accountId: String,
                             onlyMedia: Bool = true,
                             excludeReplies: Bool = true,
                             maxId: String? = nil,
                             sinceId: String? = nil,
                             minId: String? = nil,
                             limit: Int = 40) async throws -> [Status] {
            return try await pixelfedClient.statuses(for: accountId,
                                             onlyMedia: onlyMedia,
                                             excludeReplies: excludeReplies,
                                             maxId: maxId,
                                             sinceId: sinceId,
                                             minId: minId,
                                             limit: limit)
        }

        public func follow(account accountId: String) async throws -> Relationship? {
            return try await pixelfedClient.follow(for: accountId)
        }

        public func unfollow(account accountId: String) async throws -> Relationship? {
            return try await pixelfedClient.unfollow(for: accountId)
        }

        public func mute(account accountId: String) async throws -> Relationship? {
            return try await pixelfedClient.mute(for: accountId)
        }

        public func unmute(account accountId: String) async throws -> Relationship? {
            return try await pixelfedClient.unmute(for: accountId)
        }

        public func block(account accountId: String) async throws -> Relationship? {
            return try await pixelfedClient.block(for: accountId)
        }

        public func unblock(account accountId: String) async throws -> Relationship? {
            return try await pixelfedClient.unblock(for: accountId)
        }

        public func followers(account accountId: String, page: Int) async throws -> [Account] {
            return try await pixelfedClient.followers(for: accountId, page: page)
        }

        public func following(account accountId: String, page: Int) async throws -> [Account] {
            return try await pixelfedClient.following(for: accountId, page: page)
        }

        public func favourites(maxId: String? = nil,
                               sinceId: String? = nil,
                               minId: String? = nil,
                               limit: Int = 10,
                               page: Int? = nil) async throws -> [Status] {
            return try await pixelfedClient.favourites(limit: limit, page: page)
        }

        public func bookmarks(maxId: String? = nil,
                              sinceId: String? = nil,
                              minId: String? = nil,
                              limit: Int = 10,
                              page: Int? = nil) async throws -> [Status] {
            return try await pixelfedClient.bookmarks(limit: limit, page: page)
        }

        public func update(displayName: String, bio: String, website: String, locked: Bool, image: Data?) async throws -> Account {
            return try await pixelfedClient.update(displayName: displayName,
                                                   bio: bio,
                                                   website: website,
                                                   locked: locked,
                                                   image: image)
        }

        public func avatar(image: Data?) async throws -> Account {
            return try await pixelfedClient.avatar(image: image)
        }
    }
}
