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
    
    public func status(withId statusId: String, for account: AccountModel?) async throws -> Status? {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return nil
        }

        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.status(statusId: statusId)
    }
    
    func favourite(statusId: String, for account: AccountModel?) async throws -> Status? {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.favourite(statusId: statusId)
    }
    
    func unfavourite(statusId: String, for account: AccountModel?) async throws -> Status? {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unfavourite(statusId: statusId)
    }
    
    func boost(statusId: String, for account: AccountModel?) async throws -> Status? {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.boost(statusId: statusId)
    }
    
    func unboost(statusId: String, for account: AccountModel?) async throws -> Status? {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unboost(statusId: statusId)
    }
    
    func bookmark(statusId: String, for account: AccountModel?) async throws -> Status? {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.bookmark(statusId: statusId)
    }
    
    func unbookmark(statusId: String, for account: AccountModel?) async throws -> Status? {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unbookmark(statusId: statusId)
    }
    
    func new(status: Mastodon.Statuses.Components, for account: AccountModel?) async throws -> Status? {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.new(statusComponents: status)
    }
    
    func comments(to statusId: String, for account: AccountModel) async throws -> [CommentModel] {
        var commentViewModels: [CommentModel] = []
        
        let client = MastodonClient(baseURL: account.serverUrl).getAuthenticated(token: account.accessToken ?? String.empty())
        try await self.getCommentDescendants(to: statusId, client: client, showDivider: true, to: &commentViewModels)
        
        return commentViewModels
    }
    
    public func favouritedBy(statusId: String, for account: AccountModel?, page: Int) async throws -> [Account] {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.favouritedBy(for: statusId, page: page)
    }
    
    public func rebloggedBy(statusId: String, for account: AccountModel?, page: Int) async throws -> [Account] {
        guard let accessToken = account?.accessToken, let serverUrl = account?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.rebloggedBy(for: statusId, page: page)
    }
    
    private func getCommentDescendants(to statusId: String, client: MastodonClientAuthenticated, showDivider: Bool, to commentViewModels: inout [CommentModel]) async throws {
        let context = try await client.getContext(for: statusId)
        
        let descendants = context.descendants.toStatusViewModel()
        for status in descendants {
            commentViewModels.append(CommentModel(status: status, showDivider: showDivider))
            
            if status.repliesCount > 0 {
                try await self.getCommentDescendants(to: status.id, client: client, showDivider: false, to: &commentViewModels)
            }
        }
    }
}
