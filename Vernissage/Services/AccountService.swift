//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonKit

public class AccountService {
    public static let shared = AccountService()
    private init() { }
    
    public func account(withId accountId: String, for accountData: AccountData?) async throws -> Account? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }

        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.account(for: accountId)
    }
    
    public func relationships(withId accountId: String, for accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.relationships(for: accountId)
    }
    
    public func statuses(createdBy accountId: String,
                         for accountData: AccountData?,
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
        return try await client.statuses(for: accountId,
                                            onlyMedia: onlyMedia,
                                            excludeReplies: excludeReplies,
                                            maxId: maxId,
                                            sinceId: sinceId,
                                            minId: minId,
                                            limit: limit)
    }
    
    public func follow(account accountId: String, for accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.follow(for: accountId)
    }
    
    public func unfollow(account accountId: String, for accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unfollow(for: accountId)
    }
    
    public func mute(account accountId: String, for accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.mute(for: accountId)
    }
    
    public func unmute(account accountId: String, for accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unmute(for: accountId)
    }
    
    public func block(account accountId: String, for accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.block(for: accountId)
    }
    
    public func unblock(account accountId: String, for accountData: AccountData?) async throws -> Relationship? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unblock(for: accountId)
    }
    
    public func followers(account accountId: String, for accountData: AccountData?, page: Int) async throws -> [Account] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.followers(for: accountId, page: page)
    }
    
    public func following(account accountId: String, for accountData: AccountData?, page: Int) async throws -> [Account] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.following(for: accountId, page: page)
    }
    
    public func favourites(for accountData: AccountData?,
                           maxId: String? = nil,
                           sinceId: String? = nil,
                           minId: String? = nil,
                           limit: Int = 40) async throws -> [Status] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.favourites(maxId: maxId, sinceId: sinceId, minId: minId, limit: limit)
    }
    
    public func bookmarks(for accountData: AccountData?,
                          maxId: String? = nil,
                          sinceId: String? = nil,
                          minId: String? = nil,
                          limit: Int = 40) async throws -> [Status] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.bookmarks(maxId: maxId, sinceId: sinceId, minId: minId, limit: limit)
    }
}
