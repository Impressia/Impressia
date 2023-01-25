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
    
    public func tag(accountData: AccountData?, hashTag: String) async throws -> Tag? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.tag(hashtag: hashTag)
    }
    
    public func follow(accountData: AccountData?, hashTag: String) async throws -> Tag? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.follow(hashtag: hashTag)
    }
    
    public func unfollow(accountData: AccountData?, hashTag: String) async throws -> Tag? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unfollow(hashtag: hashTag)
    }
}
