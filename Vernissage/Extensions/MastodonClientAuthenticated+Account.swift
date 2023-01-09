//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonSwift

extension MastodonClientAuthenticated {
    func getAccount(for accountId: String) async throws -> Account {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.account(accountId),
            withBearerToken: token
        )
        
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
        
        return try JSONDecoder().decode(Account.self, from: data)
    }
    
    func getRelationship(for accountId: String) async throws -> Relationship? {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.relationships([accountId]),
            withBearerToken: token
        )
        
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
        
        let relationships = try JSONDecoder().decode([Relationship].self, from: data)
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
        
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
        
        return try JSONDecoder().decode([Status].self, from: data)
    }
    
    func follow(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.follow(accountId),
            withBearerToken: token
        )
        
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
               
        return try JSONDecoder().decode(Relationship.self, from: data)
    }
    
    func unfollow(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.unfollow(accountId),
            withBearerToken: token
        )
        
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
               
        return try JSONDecoder().decode(Relationship.self, from: data)
    }
    
    func getFollowers(for accountId: String, page: Int = 1) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.followers(accountId, nil, nil, nil, nil, page),
            withBearerToken: token
        )
        
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
        
        return try JSONDecoder().decode([Account].self, from: data)
    }
    
    func getFollowing(for accountId: String, page: Int = 1) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.following(accountId, nil, nil, nil, nil, page),
            withBearerToken: token
        )
        
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
        
        return try JSONDecoder().decode([Account].self, from: data)
    }
}
