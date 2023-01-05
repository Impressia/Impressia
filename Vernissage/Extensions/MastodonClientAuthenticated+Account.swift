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
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(Account.self, from: data)
    }
    
    func getRelationship(for accountId: String) async throws -> Relationship? {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.relationships([accountId]),
            withBearerToken: token
        )
        
        let (data, _) = try await urlSession.data(for: request)
        let relationships = try JSONDecoder().decode([Relationship].self, from: data)
        return relationships.first
    }
    
    func getStatuses(for accountId: String) async throws -> [Status] {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.statuses(accountId, true, true),
            withBearerToken: token
        )
        
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode([Status].self, from: data)
    }
    
    func follow(for accountId: String) async throws -> Relationship {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.follow(accountId),
            withBearerToken: token
        )
        
        let (data, _) = try await urlSession.data(for: request)        
        return try JSONDecoder().decode(Relationship.self, from: data)
    }
}
