//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

public class TagsService {
    public static let shared = TagsService()
    private init() { }
    
    public func get(tag: String, for accountData: AccountData?) async throws -> Tag? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.tag(hashtag: tag)
    }
    
    public func follow(tag: String, for accountData: AccountData?) async throws -> Tag? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.follow(hashtag: tag)
    }
    
    public func unfollow(tag: String, for accountData: AccountData?) async throws -> Tag? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unfollow(hashtag: tag)
    }
}
