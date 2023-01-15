//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public extension MastodonClientAuthenticated {
    func getAccount(for accountId: String) async throws -> Account {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.account(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Account.self, request: request)
    }
    
    func getRelationship(for accountId: String) async throws -> Relationship? {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.relationships([accountId]),
            withBearerToken: token
        )
                
        let relationships =  try await downloadJson([Relationship].self, request: request)
        return relationships.first
    }
    
    func getStatuses(for accountId: String,
                     onlyMedia: Bool = true,
                     excludeReplies: Bool = true,
                     maxId: String? = nil,
                     sinceId: String? = nil,
                     minId: String? = nil,
                     limit: Int = 40) async throws -> [Status] {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.statuses(accountId, onlyMedia, excludeReplies, maxId, sinceId, minId, limit),
            withBearerToken: token
        )
        
        return try await downloadJson([Status].self, request: request)
    }
    
    func follow(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.follow(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Relationship.self, request: request)
    }
    
    func unfollow(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.unfollow(accountId),
            withBearerToken: token
        )
        
        return try await downloadJson(Relationship.self, request: request)
    }
    
    func getFollowers(for accountId: String, page: Int = 1) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.followers(accountId, nil, nil, nil, nil, page),
            withBearerToken: token
        )
        
        return try await downloadJson([Account].self, request: request)
    }
    
    func getFollowing(for accountId: String, page: Int = 1) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.following(accountId, nil, nil, nil, nil, page),
            withBearerToken: token
        )

        return try await downloadJson([Account].self, request: request)
    }
}
