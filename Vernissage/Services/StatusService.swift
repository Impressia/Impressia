//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

public class StatusService {
    public static let shared = StatusService()
    private init() { }
    
    func favourite(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.favourite(statusId: statusId)
    }
    
    func unfavourite(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unfavourite(statusId: statusId)
    }
    
    func boost(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.boost(statusId: statusId)
    }
    
    func unboost(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unboost(statusId: statusId)
    }
    
    func bookmark(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.bookmark(statusId: statusId)
    }
    
    func unbookmark(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unbookmark(statusId: statusId)
    }
    
    func new(status: Mastodon.Statuses.Components, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.new(statusComponents: status)
    }
}
