//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonSwift

public class AccountService {
    public static let shared = AccountService()
    private init() { }
    
    public func getAccount(withId accountId: String, and accountData: AccountData?) async throws -> Account? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }

        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.getAccount(for: accountId)
    }
    
    public func getRelationship(withId accountId: String, forUser accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.getRelationship(for: accountId)
    }
    
    public func getStatuses(forAccountId accountId: String,
                            andContext accountData: AccountData?,
                            onlyMedia: Bool = true,
                            excludeReplies: Bool = true,
                            maxId: String? = nil,
                            sinceId: String? = nil,
                            minId: String? = nil,
                            limit: Int = 40) async throws -> [Status] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.getStatuses(for: accountId,
                                            onlyMedia: onlyMedia,
                                            excludeReplies: excludeReplies,
                                            maxId: maxId,
                                            sinceId: sinceId,
                                            minId: minId,
                                            limit: limit)
    }
    
    public func follow(forAccountId accountId: String, andContext accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.follow(for: accountId)
    }
    
    public func unfollow(forAccountId accountId: String, andContext accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unfollow(for: accountId)
    }
    
    public func getFollowers(forAccountId accountId: String, andContext accountData: AccountData?, page: Int) async throws -> [Account] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.getFollowers(for: accountId, page: page)
    }
    
    public func getFollowing(forAccountId accountId: String, andContext accountData: AccountData?, page: Int) async throws -> [Account] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.getFollowing(for: accountId, page: page)
    }
}
