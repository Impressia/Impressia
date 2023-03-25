//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public extension PixelfedClientAuthenticated {
    func verifyCredentials() async throws -> Account {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.verifyCredentials,
            withBearerToken: token
        )
        
        return try await downloadJson(Account.self, request: request)
    }
    
    func account(for accountId: String) async throws -> Account {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.account(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Account.self, request: request)
    }
    
    func relationships(for accountId: String) async throws -> Relationship? {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.relationships([accountId]),
            withBearerToken: token
        )
                
        let relationships =  try await downloadJson([Relationship].self, request: request)
        return relationships.first
    }
    
    func statuses(for accountId: String,
                     onlyMedia: Bool = true,
                     excludeReplies: Bool = true,
                     maxId: String? = nil,
                     sinceId: String? = nil,
                     minId: String? = nil,
                     limit: Int = 40) async throws -> [Status] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.statuses(accountId, onlyMedia, excludeReplies, maxId, sinceId, minId, limit),
            withBearerToken: token
        )
        
        return try await downloadJson([Status].self, request: request)
    }
    
    func follow(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.follow(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Relationship.self, request: request)
    }
    
    func unfollow(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.unfollow(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Relationship.self, request: request)
    }
    
    func mute(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.mute(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Relationship.self, request: request)
    }
    
    func unmute(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.unmute(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Relationship.self, request: request)
    }
    
    func block(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.block(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Relationship.self, request: request)
    }
    
    func unblock(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.unblock(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Relationship.self, request: request)
    }
    
    func followers(for accountId: String, page: Int = 1) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.followers(accountId, nil, nil, nil, nil, page),
            withBearerToken: token
        )
        
        return try await downloadJson([Account].self, request: request)
    }
    
    func following(for accountId: String, page: Int = 1) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.following(accountId, nil, nil, nil, nil, page),
            withBearerToken: token
        )

        return try await downloadJson([Account].self, request: request)
    }
    
    func favourites(maxId: EntityId? = nil,
                    sinceId: EntityId? = nil,
                    minId: EntityId? = nil,
                    limit: Int? = nil,
                    page: Page? = nil) async throws -> [Status] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Favourites.favourites(maxId, sinceId, minId, limit, page),
            withBearerToken: token
        )

        return try await downloadJson([Status].self, request: request)
    }
    
    func bookmarks(maxId: EntityId? = nil,
                   sinceId: EntityId? = nil,
                   minId: EntityId? = nil,
                   limit: Int? = nil,
                   page: Page? = nil) async throws -> [Status] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Bookmarks.bookmarks(maxId, sinceId, minId, limit, page),
            withBearerToken: token
        )

        return try await downloadJson([Status].self, request: request)
    }
    
    func update(displayName: String, bio: String, website: String, image: Data?) async throws -> Account {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.updateCredentials(displayName, bio, website, image),
            withBearerToken: token)
                
        return try await downloadJson(Account.self, request: request)
    }
    
    func avatar(image: Data?) async throws -> Account {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Account.updateAvatar(image),
            withBearerToken: token)
                
        return try await downloadJson(Account.self, request: request)
    }
}
